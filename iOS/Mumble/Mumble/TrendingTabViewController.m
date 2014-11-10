//
//  TrendingTabViewController.m
//  Mumble
//
//  Created by Stephen Sowole on 08/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import "TrendingTabViewController.h"
#import "Config.h"
#import <Parse/Parse.h>
#import "Mumble.h"
#import "HomeCustomTBCell.h"
#import "NSDate+DateTools.h"
#import "CommentsViewController.h"
#import "TagPressedViewController.h"
#import "UITabBarController+hidable.h"

@implementation TrendingTabViewController {
    
    NSMutableArray *trendingArray;
    UITableView *tableView;
    
    UIRefreshControl *refreshControl;
    
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
    
    UIView *navBarBanner;
    
    BOOL hidden;
    
    PFGeoPoint *userGeoPoint;
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self removeBackButtonText];
    
    [self createTableView];
    
    [self setNotificationObservers];
}

- (void) setNotificationObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagPressed:) name:TAG_PRESSED object:nil];
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
    
    if (!refreshControl) {
        
        refreshControl = [[UIRefreshControl alloc] init];
        
        [refreshControl addTarget:self action:@selector(retrieveMumbleData) forControlEvents:UIControlEventValueChanged];
        
        [tableView addSubview:refreshControl];
    }
}

- (void) retrieveMumbleData {
    
    PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
    
    [query setLimit:MAX_MUMBLES_ONSCREEN];
    
    [query orderByDescending:[NSString stringWithFormat:@"%@", MUMBLE_DATA_LIKES]];
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-604800];
    
    [query whereKey:@"createdAt" greaterThan:date];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            trendingArray = [[NSMutableArray alloc] init];
            
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
                
                mumble.likes = [object[MUMBLE_DATA_LIKES] longValue];
                
                mumble.comments = [object[MUMBLE_DATA_COMMENTS] longValue];
                
                [trendingArray addObject:mumble];
            }
            
            [self refreshTable];
            
            [refreshControl endRefreshing];
            
        } else {
            
            [refreshControl endRefreshing];
        }
    }];
}

- (void) tagPressed:(NSNotification*)notification {
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
            
            if (self.tabBarController.selectedIndex == TRENDING_INDEX) {
                
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
    }
}

- (void) viewDidAppear:(BOOL)animated {
    
    navBarBanner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    navBarBanner.backgroundColor = NAV_BAR_HEADER_COLOUR;
    
    [[UIApplication sharedApplication].keyWindow addSubview:navBarBanner];
    
    [self retrieveMumbleData];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void) viewDidDisappear:(BOOL)animated {
    
    [navBarBanner removeFromSuperview];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    return trendingArray.count;
}

- (UITableViewCell*) tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [table dequeueReusableCellWithIdentifier:@"Cell"];
    
    Mumble *mumble = [trendingArray objectAtIndex:indexPath.row];
    
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
    
    Mumble *mumble = [trendingArray objectAtIndex:indexPath.row];
    
    return mumble.cellHeight;
}

- (void) tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self contract];
    
    Mumble *mumble = [trendingArray objectAtIndex:indexPath.row];
    
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

#pragma mark - The Magic!

- (void) expand {
    
    if(hidden)
        return;
    
    hidden = YES;
    
    [self.tabBarController setTabBarHidden:YES
                                  animated:YES];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

- (void) contract {
    
    if(!hidden)
        return;
    
    hidden = NO;
    
    [self.tabBarController setTabBarHidden:NO
                                  animated:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
