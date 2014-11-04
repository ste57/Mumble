//
//  CommentsViewController.m
//  Mumble
//
//  Created by Stephen Sowole on 03/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import "CommentsViewController.h"
#import "Config.h"
#import "CommentsTableViewCell.h"

@implementation CommentsViewController {
    
    UITableView *tableView;
    NSMutableArray *commentsArray;
}

@synthesize mumble;

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = mumble.content;

    NSDictionary *titleTextAttrs = @{NSFontAttributeName: MUMBLE_CONTENT_TEXT_FONT};
    [self.navigationController.navigationBar setTitleTextAttributes:titleTextAttrs];
    
    [self createTableView];
}


- (void) createTableView {
    
    CGRect window = [[UIScreen mainScreen] bounds];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, window.size.width, window.size.height) style:UITableViewStylePlain];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    tableView.separatorColor = [UIColor colorWithRed:0.875 green:0.875 blue:0.875 alpha:0.7];

    [tableView registerClass:[CommentsTableViewCell class] forCellReuseIdentifier:@"cell"];

    tableView.estimatedRowHeight = 50.0;
    
    [self.view addSubview:tableView];

    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 10;//commentsArray.count;
}

- (UITableViewCell*) tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CommentsTableViewCell *cell;

    if (!cell){
        cell = [[CommentsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    /*Mumble *mumble = [Mumbles objectAtIndex:indexPath.row];
    
    HomeCustomTBCell *cell = [[HomeCustomTBCell alloc] initWithFrame:CGRectZero];
    
    cell.mumble = mumble;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell createLabels];
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }*/
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    // Mumble *mumble = [Mumbles objectAtIndex:indexPath.row];

    return 80.0;//mumble.cellHeight;
}

- (void) tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [table deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) tableView:(UITableView *)table moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    [table deselectRowAtIndexPath:sourceIndexPath animated:NO];
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
