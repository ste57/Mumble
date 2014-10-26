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

#define TITLE @"Home"
#define TAB_TITLE @"Home"


///// THINGS TO DO //////
//
// - create post part of app
// - add likes/Comments
// - add Locations
//
/////////////////////////


@implementation HomeTab {
    
    NSMutableArray *Mumbles;
    UITableView *tableView;
    
    UIRefreshControl *refreshControl;
    
    CGFloat startContentOffset;
    CGFloat lastContentOffset;

    BOOL hidden;
}

- (void) checkUserParseID {
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:USERID]) {
        
        PFObject *user = [PFObject objectWithClassName:USER_DATA_CLASS];
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
             
                [[NSUserDefaults standardUserDefaults] setObject:user.objectId forKey:USERID];
            }
        }];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self checkUserParseID];
    
    self.title = TAB_TITLE;
    
    self.navigationItem.title = TITLE;
    
    [self removeBackButtonText];
    
    [self createTableView];
    
    [self retrieveMumbleData];
    
    [self addStatusBarBanner];
}

- (void) addStatusBarBanner {
    
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    top.backgroundColor = [UIColor colorWithRed:0.46 green:0.64 blue:0.78 alpha:1.0];
    [currentWindow addSubview:top];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void) retrieveMumbleData {
    
    PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
    
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            Mumbles = [[NSMutableArray alloc] init];
            
            Mumble *mumble;
            
            for (PFObject *object in objects) {
                
                mumble = [[Mumble alloc] init];
                
                mumble.objectId = object.objectId;
                mumble.content = object[MUMBLE_DATA_CLASS_CONTENT];
                mumble.msgLocation = object[MUMBLE_DATA_MSG_LOCATION];
                
                /////// calculate mumble height
                
                NSString *text = [NSString stringWithFormat:@"%@ %@", mumble.content, mumble.msgLocation];
                
                CGSize constraint = CGSizeMake((self.view.frame.size.width - (CELL_PADDING*2)), 20000.0f);
                
                CGSize size = [text boundingRectWithSize: constraint options: NSStringDrawingUsesLineFragmentOrigin
                                              attributes: @{ NSFontAttributeName: MUMBLE_CONTENT_TEXT_FONT} context: nil].size;
                
                mumble.cellHeight = HOME_TBCELL_DEFAULT_HEIGHT + size.height;
                
                ///////
                
                mumble.createdAt = object.createdAt.timeAgoSinceNow;
                
                /////// get number of likes
                
                //PFQuery *likesQuery = [PFQuery queryWithClassName:LIKES_DATA_CLASS];
                
                
                /////// get comments
                
                [Mumbles addObject:mumble];
            }
            
            [self refreshTable];
            [refreshControl endRefreshing];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return Mumbles.count;
}

- (UITableViewCell*) tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [table dequeueReusableCellWithIdentifier:@"Cell"];
    
    Mumble *mumble = [Mumbles objectAtIndex:indexPath.row];
    
    HomeCustomTBCell *cell = [[HomeCustomTBCell alloc] initWithFrame:CGRectZero];
    
    cell.mumble = mumble;
    
    [cell createLabels];
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Mumble *mumble = [Mumbles objectAtIndex:indexPath.row];
    
    return mumble.cellHeight;
}

- (void) tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [table deselectRowAtIndexPath:indexPath animated:NO];
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

@end
