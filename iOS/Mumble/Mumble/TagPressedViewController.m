//
//  TagPressedViewController.m
//  Mumble
//
//  Created by Stephen Sowole on 04/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import "TagPressedViewController.h"
#import "HomeCustomTBCell.h"
#import "Config.h"
#import <Parse/Parse.h>
#import "Mumble.h"
#import "NSDate+DateTools.h"
#import "CommentsViewController.h"
#import "TagPressedViewController.h"
#import "PostMessageViewController.h"

@implementation TagPressedViewController {
    
    NSMutableArray *mumbles;
    UITableView *tableView;
    
    UIRefreshControl *refreshControl;
    
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
    
    UIView *navBarBanner;
    
    CLLocationManager *locationManager;
    
    NSString *userID;
    
    BOOL hidden;
}

- (void) viewDidAppear:(BOOL)animated {
    
    navBarBanner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    navBarBanner.backgroundColor = NAV_BAR_HEADER_COLOUR;
    
    [[UIApplication sharedApplication].keyWindow addSubview:navBarBanner];
}

- (void) viewDidDisappear:(BOOL)animated {
    
    [navBarBanner removeFromSuperview];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    userID = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:USERID];
    
    [self removeBackButtonText];
    
    [self addNavigationBarItems];
    
    [self createTableView];
    
    [self retrieveMumbleData];
    
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
    
    [locationManager stopUpdatingLocation];
}

- (void) setNotificationObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retrieveMumbleData) name:REFRESH_TABLEVIEW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showComments:) name:COMMENTS_PRESSED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagPressed:) name:TAG_PRESSED object:nil];
}

- (void) tagPressed:(NSNotification*)notification {
    
    NSString *tag = [notification object];
    
    if (![tag isEqual:[[[self.navigationController viewControllers] lastObject] title]]) {
        
        [self contract];
        
        TagPressedViewController *tagPressedVC = [[TagPressedViewController alloc] init];
        
        tagPressedVC.title = tag;
        
        tagPressedVC.view.backgroundColor = [UIColor whiteColor];
        
        [self.navigationController pushViewController:tagPressedVC animated:YES];
    }
}

- (void) showComments:(NSNotification*)notification {
    
    [self contract];
    
    Mumble *mumble = [notification object];
    
    CommentsViewController *commentsVC = [[CommentsViewController alloc] init];
    
    commentsVC.mumble = mumble;
    
    [self.navigationController pushViewController:commentsVC animated:YES];
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

- (void) retrieveMumbleData {
    
    PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
    
    [query orderByDescending:@"createdAt"];
    
    [query setLimit:MAX_MUMBLES_ONSCREEN];
    
    [query whereKey:MUMBLE_DATA_TAGS equalTo:self.title];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            mumbles = [[NSMutableArray alloc] init];
            
            Mumble *mumble;
            
            for (PFObject *object in objects) {
                
                mumble = [[Mumble alloc] init];
                
                mumble.objectId = object.objectId;
                
                mumble.tags = object[MUMBLE_DATA_TAGS];
                
                mumble.content = [NSString stringWithFormat:@"%@", object[MUMBLE_DATA_CLASS_CONTENT]];
                
                CGSize constraint = CGSizeMake((self.view.frame.size.width - (CELL_PADDING*2)), 20000.0f);
                
                CGSize size = [mumble.content boundingRectWithSize: constraint options: NSStringDrawingUsesLineFragmentOrigin
                                                        attributes: @{ NSFontAttributeName: MUMBLE_CONTENT_TEXT_FONT} context: nil].size;
                
                mumble.cellHeight = HOME_TBCELL_DEFAULT_HEIGHT + size.height;
                
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

- (void) addRefreshButton {
    
    if (!refreshControl) {
        
        refreshControl = [[UIRefreshControl alloc] init];
        
        [refreshControl addTarget:self action:@selector(retrieveMumbleData) forControlEvents:UIControlEventValueChanged];
        
        [tableView addSubview:refreshControl];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Mumble *mumble = [mumbles objectAtIndex:indexPath.row];
    
    return mumble.cellHeight;
}

- (void) tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self contract];
    
    Mumble *mumble = [mumbles objectAtIndex:indexPath.row];
    
    CommentsViewController *commentsVC = [[CommentsViewController alloc] init];
    
    commentsVC.mumble = mumble;
    
    [self.navigationController pushViewController:commentsVC animated:YES];
}

- (void) tableView:(UITableView *)table moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    [table deselectRowAtIndexPath:sourceIndexPath animated:NO];
}

- (void) removeBackButtonText {
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
}

- (void) addNavigationBarItems {
    
    // Post Message
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(postMessage)];
    [postButton setImage:[UIImage imageNamed:@"postIcon"]];
    
    self.navigationItem.rightBarButtonItem = postButton;
}

#pragma mark - The Magic!

- (void) expand {
    
    if(hidden)
        return;
    
    hidden = YES;
    
    [self.tabBarController setTabBarHidden:YES animated:YES];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void) contract {
    
    if(!hidden)
        return;
    
    hidden = NO;
    
    [self.tabBarController setTabBarHidden:NO animated:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
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

- (void) postMessage {
    
    navBarBanner.hidden = YES;
    PostMessageViewController *post = [[PostMessageViewController alloc] init];
    post.tagTitle = self.title;
    [self presentViewController:post animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
