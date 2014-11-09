//
//  HomeTab.m
//  Mumble
//
//  Created by Stephen Sowole on 18/10/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import "HomeTab.h"
#import "HomeCustomTBCell.h"
#import "Config.h"
#import <Parse/Parse.h>
#import "Mumble.h"
#import "NSDate+DateTools.h"
#import "CommentsViewController.h"
#import "TagPressedViewController.h"

@implementation HomeTab {
    
    NSMutableArray *mumbles;
    NSArray *searchResults;
    UITableView *tableView;
    
    UIRefreshControl *refreshControl;
    
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
    
    UIView *navBarBanner;
    
    CLLocationManager *locationManager;
    
    BOOL hidden;
    
    NSString *userID;
    
    PFGeoPoint *userGeoPoint;
    
    UISearchBar *searchBar;
    UISearchDisplayController *searchBarController;
}

@synthesize isMainViewController, showHot, showNew;

- (void) checkUserParseID {
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:USERID]) {
        
        PFObject *user = [PFObject objectWithClassName:USER_DATA_CLASS];
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                userID = user.objectId;
                
                [[NSUserDefaults standardUserDefaults] setObject:userID forKey:USERID];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }];
        
    } else {
        
        userID = [[NSUserDefaults standardUserDefaults] objectForKey:USERID];
    }
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self checkUserParseID];
    
    [self removeBackButtonText];
    
    [self addNavigationBarItems];
    
    [self createTableView];
    
    [self createSearchBar];
    
    [self setNotificationObservers];
    
    [self initiateCoreLocation];
    
    [locationManager startUpdatingLocation];
}

- (void) createSearchBar {
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,0,0)];
    searchBar.delegate = self;
    
    searchBar.placeholder = SEARCH_BAR_PLACEHOLDER;
    searchBar.showsCancelButton = YES;
    
    searchBar.hidden = YES;
    
    searchBarController = [[UISearchDisplayController alloc]
                           initWithSearchBar:searchBar
                           contentsController:self];
    
    searchBarController.delegate = self;
    searchBarController.searchResultsDataSource = self;
    searchBarController.searchResultsDelegate = self;
}

- (void) initiateCoreLocation {
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    PFQuery *query = [PFQuery queryWithClassName:USER_DATA_CLASS];
    
    [query getObjectInBackgroundWithId:userID block:^(PFObject *userPFObject, NSError *error) {
        
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:newLocation.coordinate.latitude
                                                      longitude:newLocation.coordinate.longitude];
        
        [userPFObject setObject:geoPoint forKey:USER_DATA_LOCATION];
        [userPFObject saveInBackground];
    }];
    
    userGeoPoint = [PFGeoPoint geoPointWithLatitude:newLocation.coordinate.latitude
                                          longitude:newLocation.coordinate.longitude];
    
    [locationManager stopUpdatingLocation];
    
    [self retrieveMumbleData];
}

- (void) setNotificationObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retrieveMumbleData) name:REFRESH_TABLEVIEW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showComments:) name:COMMENTS_PRESSED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagPressed:) name:TAG_PRESSED object:nil];
}

- (void) tagPressed:(NSNotification*)notification {

    if (self.tabBarController.selectedIndex == HOME_INDEX) {
        
        NSString *tag = [notification object];
        
        if (![tag isEqual:[[[self.navigationController viewControllers] lastObject] title]]) {
            
            [self contract];
            
            TagPressedViewController *tagPressedVC = [[TagPressedViewController alloc] init];
            
            tagPressedVC.title = tag;
            
            tagPressedVC.view.backgroundColor = [UIColor whiteColor];
            
            [self.navigationController pushViewController:tagPressedVC animated:YES];
        }
    }
}

- (void) showComments:(NSNotification*)notification {
    
    [self contract];
    
    Mumble *mumble = [notification object];
    
    CommentsViewController *commentsVC = [[CommentsViewController alloc] init];
    
    commentsVC.mumble = mumble;
    
    [self.navigationController pushViewController:commentsVC animated:YES];
}

- (void) addNavigationBarItems {
    
    // Post Message
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(postMessage)];
    [postButton setImage:[UIImage imageNamed:@"postIcon"]];
    
    self.navigationItem.rightBarButtonItem = postButton;
    
    // Search Location
    /* UIBarButtonItem *locationButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(searchLocation)];
     [locationButton setImage:[UIImage imageNamed:@"location"]];
     
     self.navigationItem.leftBarButtonItem = locationButton;*/
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchLocation)];
    
    self.navigationItem.leftBarButtonItem = searchButton;
}

- (void) postMessage {

    [navBarBanner performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:NO];
    PostMessageViewController *post = [[PostMessageViewController alloc] init];
    [self presentViewController:post animated:YES completion:nil];
}

- (void) searchLocation {
    
    searchBar.hidden = NO;
    
    tableView.tableHeaderView = searchBar;
    
    self.navigationController.navigationBarHidden = YES;
    
    searchResults = [[NSArray alloc] init];
    
    [searchBarController setActive:YES animated:YES];
    [searchBar becomeFirstResponder];
    
    [self expand];
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    
    [self searchBarCancelButtonClicked:searchBar];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)theSearchBar {
    
    searchBar.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
    
    tableView.tableHeaderView = NULL;
    searchResults = [[NSArray alloc] init];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    
    [self searchForTag];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBarItem {
    
    if (searchBar.text.length < 1) {
        
        searchBar.text = TAG_IDENTIFIER;
        
        [self getPopularTags];
    }
}

- (void) getPopularTags {
    
    PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
    
    [query setLimit:POPULAR_TAG_LIMIT];
    
    [query whereKey:MUMBLE_DATA_LOCATION nearGeoPoint:userGeoPoint];
    
    [query orderByDescending:[NSString stringWithFormat:@"createdAt"]];
    
    [query selectKeys:@[MUMBLE_DATA_TAGS]];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    searchResults = [[NSArray alloc] init];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        for (PFObject *object in objects) {
            
            [array addObjectsFromArray:object[MUMBLE_DATA_TAGS]];
        }
        
        for (NSString *string in array) {
            
            if ([dictionary objectForKey:string]) {
                
                NSInteger number = [[dictionary objectForKey:string] integerValue];
                number++;
                [dictionary setObject:[NSNumber numberWithInteger:number] forKey:string];
                
            } else {
                
                [dictionary setValue:[NSNumber numberWithInteger:0] forKey:string];
            }
        }
        
        searchResults = [dictionary keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
            
            if ([obj1 integerValue] > [obj2 integerValue]) {
                
                return (NSComparisonResult)NSOrderedAscending;
            }
            if ([obj1 integerValue] < [obj2 integerValue]) {
                
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        [[searchBarController searchResultsTableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}

- (void) searchBar:(UISearchBar *)searchBarItem textDidChange:(NSString *)searchText {
    
    if (searchBar.text.length == 1) {
        
        [self getPopularTags];
    }
    
    if (searchBar.text.length < 1) {
        
        searchBar.text = TAG_IDENTIFIER;
        
    } else {
        
        [self searchForTag];
    }
}

- (void) searchForTag {
    
    if (searchBar.text.length > 1) {
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        searchResults = [[NSArray alloc] init];
        
        PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
        
        [query setLimit:20];
        
        [query selectKeys:@[MUMBLE_DATA_TAGS]];
        
        [query whereKey:MUMBLE_DATA_TAGS equalTo:searchBar.text];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            for (PFObject *object in objects) {
                
                NSArray *arr = object[MUMBLE_DATA_TAGS];
                
                for (NSString *string in arr) {
                    
                    if ([string isEqual:searchBar.text]) {
                        
                        [array addObject:string];
                    }
                }
            }
            
            NSMutableArray * unique = [NSMutableArray array];
            NSMutableSet * processed = [NSMutableSet set];
            
            for (NSString * string in array) {
                
                if ([processed containsObject:string] == NO) {
                    [unique addObject:string];
                    [processed addObject:string];
                }
            }
            
            searchResults = unique;
            
            [[searchBarController searchResultsTableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    
    if (isMainViewController) {
    
        navBarBanner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
        navBarBanner.backgroundColor = NAV_BAR_HEADER_COLOUR;
    
        [[UIApplication sharedApplication].keyWindow addSubview:navBarBanner];
    }
    
    if (userGeoPoint) {
        
        [self retrieveMumbleData];
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    
    if (isMainViewController) {
        [navBarBanner removeFromSuperview];
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void) retrieveMumbleData {
    
    PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
    
    [query setLimit:MAX_MUMBLES_ONSCREEN];

    if (showNew) {
        
        [query whereKey:MUMBLE_DATA_LOCATION nearGeoPoint:userGeoPoint];
        
        [query orderByDescending:[NSString stringWithFormat:@"createdAt,%@", MUMBLE_DATA_LOCATION]];
        
    } else if (showHot) {

        [query orderByDescending:[NSString stringWithFormat:@"%@,createdAt", MUMBLE_DATA_LIKES]];
        
        [query whereKey:MUMBLE_DATA_LOCATION nearGeoPoint:userGeoPoint];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            mumbles = [[NSMutableArray alloc] init];
            
            Mumble *mumble;
            
            for (PFObject *object in objects) {
                
                mumble = [[Mumble alloc] init];
                
                mumble.objectId = object.objectId;
                
                mumble.tags = object[MUMBLE_DATA_TAGS];
                
                mumble.content = [NSString stringWithFormat:@"%@", object[MUMBLE_DATA_CLASS_CONTENT]];
                
                /////// calculate mumble height
                
                CGSize constraint = CGSizeMake((self.view.frame.size.width - (CELL_PADDING*2)), 20000.0f);
                
                CGSize size = [mumble.content boundingRectWithSize: constraint options: NSStringDrawingUsesLineFragmentOrigin
                                                        attributes: @{ NSFontAttributeName: MUMBLE_CONTENT_TEXT_FONT} context: nil].size;
                
                mumble.cellHeight = HOME_TBCELL_DEFAULT_HEIGHT + size.height;
                
                //////
                
                mumble.createdAt = object.createdAt.timeAgoSinceNow;
                
                mumble.likes = [object[MUMBLE_DATA_LIKES] longValue];
                
                mumble.comments = [object[MUMBLE_DATA_COMMENTS] longValue];
                
                [mumbles addObject:mumble];
            }
            
            [self refreshTable];
            
            [refreshControl endRefreshing];
            
        } else {
            
            [refreshControl endRefreshing];
        }
    }];
}

- (void) refreshTable {
    
    [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void) createTableView {
    
    CGRect window = [[UIScreen mainScreen] bounds];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, window.size.width, window.size.height) style:UITableViewStylePlain];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    tableView.separatorColor = [UIColor colorWithRed:0.875 green:0.875 blue:0.875 alpha:0.7];
    
    [self.view addSubview:tableView];
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self addRefreshButton];
}

- (void) addRefreshButton {
    
    if (!refreshControl) {
        
        refreshControl = [[UIRefreshControl alloc] init];
        
        [refreshControl addTarget:self action:@selector(retrieveMumbleData) forControlEvents:UIControlEventValueChanged];
        
        [tableView addSubview:refreshControl];
    }
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    if (table == tableView) {
        
        return mumbles.count;
        
    } else {
        
        return searchResults.count;
    }
}

- (UITableViewCell*) tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [table dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (table == tableView) {
        
        Mumble *mumble = [mumbles objectAtIndex:indexPath.row];
        
        HomeCustomTBCell *cell = [[HomeCustomTBCell alloc] initWithFrame:CGRectZero];
        
        cell.mumble = mumble;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell createLabels];
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        return cell;
        
    } else {
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        
        cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
        
        cell.textLabel.textColor = NAV_BAR_COLOUR;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (table == tableView) {
        
        Mumble *mumble = [mumbles objectAtIndex:indexPath.row];
        
        return mumble.cellHeight;
        
    } else {
        
        return 50.0;
    }
}

- (void) tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (table == tableView) {
        
        [self contract];
        
        Mumble *mumble = [mumbles objectAtIndex:indexPath.row];
        
        CommentsViewController *commentsVC = [[CommentsViewController alloc] init];
        
        commentsVC.mumble = mumble;
        
        [self.navigationController pushViewController:commentsVC animated:YES];
        
    } else {
        
        NSString *tag = [searchResults objectAtIndex:indexPath.row];
        
        if (![tag isEqual:[[[self.navigationController viewControllers] lastObject] title]]) {
            
            [self contract];
            
            TagPressedViewController *tagPressedVC = [[TagPressedViewController alloc] init];
            
            tagPressedVC.title = tag;
            
            tagPressedVC.view.backgroundColor = [UIColor whiteColor];
            
            [self.navigationController pushViewController:tagPressedVC animated:YES];
        }
    }
}

- (void) tableView:(UITableView *)table moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    [table deselectRowAtIndexPath:sourceIndexPath animated:NO];
}

- (void) removeBackButtonText {
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
}

#pragma mark - The Magic!

- (void) expand {
    
    if ([searchBar isHidden]) {
        
        if(hidden)
            return;
        
        hidden = YES;
        
        [self.tabBarController setTabBarHidden:YES
                                      animated:YES];
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
    }
}

- (void) contract {
    
    if ([searchBar isHidden]) {
        
        if(!hidden)
            return;
        
        hidden = NO;
        
        [self.tabBarController setTabBarHidden:NO
                                      animated:YES];
        
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    startContentOffset = lastContentOffset = scrollView.contentOffset.y;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat differenceFromStart = startContentOffset - currentOffset;
    CGFloat differenceFromLast = lastContentOffset - currentOffset;
    lastContentOffset = currentOffset;
    
    if((differenceFromStart) < 0) {
        // scroll up
        if(scrollView.isTracking && (abs(differenceFromLast)>1))
            [self expand];
        
    } else {
        if(scrollView.isTracking && (abs(differenceFromLast)>1))
            [self contract];
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (BOOL) scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    
    [self contract];
    return YES;
}

@end
