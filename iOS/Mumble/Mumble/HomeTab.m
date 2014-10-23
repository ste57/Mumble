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
#import "UIViewController+ScrollingNavbar.h"
#import "NSDate+DateTools.h"

#define TITLE @"Home"
#define TAB_TITLE @"Home"

// Parse Info

#define MUMBLE_DATA_CLASS @"Mumble"
#define MUMBLE_DATA_CLASS_CONTENT @"content"
#define MUMBLE_DATA_MSG_LOCATION @"msgLocation"


///// THINGS TO DO //////
//
// - create unique userID
// - create post part of app
// - add likes
//
/////////////////////////


@implementation HomeTab {
    
    NSMutableArray *Mumbles;
    UITableView *tableView;
    
    UIRefreshControl *refreshControl;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    //[self followScrollView:tableView];
}

/*- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self showNavBarAnimated:NO];
}*/

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = TAB_TITLE;
    
    self.navigationItem.title = TITLE;
    
    [self removeBackButtonText];
    
    [self createTableView];
    
    [self retrieveMumbleData];
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
    
    //self.navigationController.scrollNavigationBar.scrollView = nil;
    
    [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    // self.navigationController.scrollNavigationBar.scrollView = tableView;
}

- (void) createTableView {
    
    CGRect window = [[UIScreen mainScreen] bounds];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, window.size.width, window.size.height) style:UITableViewStylePlain];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
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

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
