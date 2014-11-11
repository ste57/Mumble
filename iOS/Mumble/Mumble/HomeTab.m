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
#import "SearchViewController.h"

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
    
    SearchViewController *searchViewController;
}

@synthesize isMainViewController, showHot, showNew;

- (void) checkUserParseID {
    
    if (isMainViewController) {
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:USERID]) {
            
            PFObject *user = [PFObject objectWithClassName:USER_DATA_CLASS];
            
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    
                    userID = user.objectId;
                    
                    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:USERID];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    if (userID) {
                        
                        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                        [currentInstallation addUniqueObject:[NSString stringWithFormat:@"%@%@", USER_PREFIX, userID] forKey:@"channels"];
                        [currentInstallation saveInBackground];
                    }
                }
            }];
            
        } else {
            
            userID = [[NSUserDefaults standardUserDefaults] objectForKey:USERID];
            
            if (userID) {
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObject:[NSString stringWithFormat:@"%@%@", USER_PREFIX, userID] forKey:@"channels"];
                [currentInstallation saveInBackground];
            }
        }
    }
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self checkUserParseID];
    
    [self removeBackButtonText];
    
    [self addNavigationBarItems];
    
    [self createTableView];
    
    [self setNotificationObservers];
    
    [self initiateCoreLocation];
    
    [locationManager startUpdatingLocation];
}

- (void) initiateCoreLocation {
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
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
    
    if (self.tabBarController.selectedIndex == HOME_INDEX && isMainViewController) {
        
        [self contract];
        
        Mumble *mumble = [notification object];
        
        CommentsViewController *commentsVC = [[CommentsViewController alloc] init];
        
        commentsVC.mumble = mumble;
        
        [self.navigationController pushViewController:commentsVC animated:YES];
    }
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

- (void) searchLocation {
    
    if (isMainViewController) {
        [navBarBanner performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:NO];
        searchViewController = [[SearchViewController alloc] init];
        searchViewController.userGeoPoint = userGeoPoint;
        [self presentViewController:searchViewController animated:YES completion:nil];
    }
}

- (void) postMessage {
    
    navBarBanner.alpha = 0;
    [navBarBanner performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:NO];
    PostMessageViewController *post = [[PostMessageViewController alloc] init];
    [self presentViewController:post animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (isMainViewController) {
        
        self.screenName = @"About Screen";
        
    } else {
        
        self.screenName = @"Hot";
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
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
            
            PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
            
            [query setLimit:MAX_MUMBLES_ONSCREEN];
            
            //[query whereKey:MUMBLE_DATA_FLAG lessThan:@(MUMBLE_FLAG_FOR_DELETE)];
            
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
                        
                        mumble.userID = object[MUMBLE_DATA_USER];
                        
                        /////// calculate mumble height
                        
                        CGSize constraint = CGSizeMake((self.view.frame.size.width - (CELL_PADDING*2)), 20000.0f);
                        
                        CGSize size = [mumble.content boundingRectWithSize: constraint options: NSStringDrawingUsesLineFragmentOrigin
                                                                attributes: @{ NSFontAttributeName: MUMBLE_CONTENT_TEXT_FONT} context: nil].size;
                        
                        mumble.cellHeight = HOME_TBCELL_DEFAULT_HEIGHT + size.height;
                        
                        //////
                        
                        mumble.createdAt = object.createdAt.timeAgoSinceNow;
                        
                        mumble.shortCreatedAt = object.createdAt.shortTimeAgoSinceNow;
                        
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
    }
}

- (void) refreshTable {
    
    [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void) createTableView {
    
    CGRect window = [[UIScreen mainScreen] bounds];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, window.size.width, window.size.height - 20) style:UITableViewStylePlain];
    
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
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
            
            if (!refreshControl) {
                
                refreshControl = [[UIRefreshControl alloc] init];
                
                [refreshControl addTarget:self action:@selector(retrieveMumbleData) forControlEvents:UIControlEventValueChanged];
                
                [tableView addSubview:refreshControl];
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    return mumbles.count;
}

- (UITableViewCell*) tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [table dequeueReusableCellWithIdentifier:@"Cell"];
    
    Mumble *mumble = [mumbles objectAtIndex:indexPath.row];
    
    HomeCustomTBCell *cell = [[HomeCustomTBCell alloc] initWithFrame:CGRectZero];
    
    cell.mumble = mumble;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell createLabels];
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Mumble *mumble = [mumbles objectAtIndex:indexPath.row];
    
    return mumble.cellHeight;
}

- (void) tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self contract];
    
    Mumble *mumble = [mumbles objectAtIndex:indexPath.row];
    
    CommentsViewController *commentsVC = [[CommentsViewController alloc] init];
    
    commentsVC.mumble = mumble;
    
    [commentsVC pushCommentsCount];
    
    [self.navigationController pushViewController:commentsVC animated:YES];
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
    
    //if ([searchBar isHidden]) {
    
    if(hidden)
        return;
    
    hidden = YES;
    
    [self.tabBarController setTabBarHidden:YES
                                  animated:YES];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //}
}

- (void) contract {
    
    // if ([searchBar isHidden]) {
    
    if(!hidden)
        return;
    
    hidden = NO;
    
    [self.tabBarController setTabBarHidden:NO
                                  animated:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // }
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
