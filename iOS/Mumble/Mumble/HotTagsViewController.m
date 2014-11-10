//
//  HotTagsViewController.m
//  Mumble
//
//  Created by Stephen Sowole on 09/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import "HotTagsViewController.h"
#import "Config.h"
#import <Parse/Parse.h>
#import "TagPressedViewController.h"

@implementation HotTagsViewController {
    
    NSArray *trendingArray;
    UITableView *tableView;
    
    UIRefreshControl *refreshControl;
    
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
    
    UIView *navBarBanner;
    
    BOOL hidden;
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self removeBackButtonText];
    
    [self createTableView];
}

- (void) refreshTable {
    
    [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void) removeBackButtonText {
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
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

- (void) retrieveMumbleData {
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
            
            PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
            
            [query setLimit:TRENDING_TAG_LIMIT];
            
            [query selectKeys:@[MUMBLE_DATA_TAGS]];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            
            trendingArray = [[NSArray alloc] init];
            
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
                
                trendingArray = [dictionary keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
                    
                    if ([obj1 integerValue] > [obj2 integerValue]) {
                        
                        return (NSComparisonResult)NSOrderedAscending;
                    }
                    if ([obj1 integerValue] < [obj2 integerValue]) {
                        
                        return (NSComparisonResult)NSOrderedDescending;
                    }
                    
                    return (NSComparisonResult)NSOrderedSame;
                }];
                
                [self refreshTable];
            }];
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
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    
    cell.textLabel.text = [trendingArray objectAtIndex:indexPath.row];
    
    cell.textLabel.textColor = NAV_BAR_HEADER_COLOUR;
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60.0;
}

- (void) tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self contract];
    
    TagPressedViewController *tagPressedVC = [[TagPressedViewController alloc] init];
    
    tagPressedVC.title = [trendingArray objectAtIndex:indexPath.row];
    
    tagPressedVC.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController pushViewController:tagPressedVC animated:YES];
    
    [table deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) tableView:(UITableView *)table moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    [table deselectRowAtIndexPath:sourceIndexPath animated:NO];
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
