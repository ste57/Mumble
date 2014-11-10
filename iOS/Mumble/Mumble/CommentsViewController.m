//
//  CommentsViewController.m
//  Mumble
//
//  Created by Stephen Sowole on 03/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import <Social/Social.h>
#import "CommentsViewController.h"
#import "Config.h"
#import "CommentsTableViewHeader.h"
#import "CommentsTableViewCell.h"
#import "Comment.h"
#import <Parse/Parse.h>
#import "NSDate+DateTools.h"

@implementation CommentsViewController {
    
    NSMutableArray *commentsArray, *flaggedArray;
    UIRefreshControl *refreshControl;
}

@synthesize mumble;

- (void) viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Comments";
    //NSDictionary *titleTextAttrs = @{NSFontAttributeName: MUMBLE_CONTENT_TEXT_FONT};
    //[self.navigationController.navigationBar setTitleTextAttributes:titleTextAttrs];
    
    //[self createTableView];
    
    self.bounces = YES;
    self.shakeToClearEnabled = YES;
    self.keyboardPanningEnabled = YES;
    self.inverted = NO;
    
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor colorWithRed:0.875 green:0.875 blue:0.875 alpha:0.7];
    [self.tableView registerClass:[CommentsTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.textView.placeholder = NSLocalizedString(@"Message", nil);
    self.textView.placeholderColor = [UIColor lightGrayColor];
    self.textView.layer.borderColor = [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0].CGColor;
    self.textView.pastableMediaTypes = SLKPastableMediaTypeAll|SLKPastableMediaTypePassbook;
    
    [self.rightButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    
    [self.textInputbar.editorTitle setTextColor:[UIColor darkGrayColor]];
    [self.textInputbar.editortLeftButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [self.textInputbar.editortRightButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    self.textInputbar.autoHideRightButton = YES;
    self.textInputbar.maxCharCount = MUMBLE_CHARACTER_LIMIT;
    self.textInputbar.counterStyle = SLKCounterStyleSplit;
    
    self.typingIndicatorView.canResignByTouch = YES;
    
    [self.autoCompletionView registerClass:[CommentsTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    // Create Table View Header
    
    CommentsTableViewHeader *headerView = [[CommentsTableViewHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, mumble.cellHeight + 20)];
    headerView.mumble = mumble;
    [headerView createLabels];
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView setLabelNames];
    headerView.delegate = self;
    [self.tableView setTableHeaderView:headerView];
    
    [self addRefreshButton];
    [self retrieveComments];
    
    [self addNavigationBarItems];
}

- (void) addNavigationBarItems {
    
    UIButton* aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    aButton.frame = CGRectMake(0.0, 40.0, 15.0, 21.0);
    [aButton setBackgroundImage:[UIImage imageNamed:@"flag"] forState:UIControlStateNormal];
    [aButton addTarget:self action:@selector(flagMessage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *anUIBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    self.navigationItem.rightBarButtonItem = anUIBarButtonItem;
}

- (void) retrieveFlaggedPostsFromUser {
    
    flaggedArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *tempArray = (NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:FLAG_ARRAY];
    
    for (NSString *_id in tempArray) {
        
        [flaggedArray addObject:_id];
    }
}

- (void) flagMessage {
    
    [self retrieveFlaggedPostsFromUser];
    
    if (![flaggedArray containsObject:mumble.objectId]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Report Message"
                                                        message:@"Do you want to report this message?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        [self retrieveFlaggedPostsFromUser];
        
        PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
        
        [query getObjectInBackgroundWithId:mumble.objectId block:^(PFObject *mumblePFObject, NSError *error) {
            
            [mumblePFObject incrementKey:MUMBLE_DATA_FLAG byAmount:[NSNumber numberWithInt:1]];
            
            [mumblePFObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                [flaggedArray addObject:mumble.objectId];
                [[NSUserDefaults standardUserDefaults] setObject:flaggedArray forKey:FLAG_ARRAY];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }];
            
        }];
    }
}

- (void) pushCommentsCount {
    
    [self addMumbleCommentCount];
}

- (void) retrieveComments {
    
    PFQuery *query = [PFQuery queryWithClassName:COMMENTS_DATA_CLASS];
    
    [query orderByAscending:@"createdAt"];
    
    [query setLimit:MAX_MUMBLES_ONSCREEN];
    
    [query whereKey:COMMENTS_MUMBLE_ID equalTo:mumble.objectId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            commentsArray = [[NSMutableArray alloc] init];
            
            Comment *comment;
            
            for (PFObject *object in objects) {
                
                comment = [[Comment alloc] init];
                
                comment.objectId = object.objectId;
                
                comment.content = [NSString stringWithFormat:@"%@", object[COMMENTS_DATA_CONTENT]];
                
                comment.likes = [object[COMMENTS_DATA_LIKES] longValue];
                
                CGSize constraint = CGSizeMake((self.view.frame.size.width - (CELL_PADDING*2)), 20000.0f);
                
                CGSize size = [comment.content boundingRectWithSize: constraint options: NSStringDrawingUsesLineFragmentOrigin
                                                         attributes: @{ NSFontAttributeName: MUMBLE_CONTENT_TEXT_FONT} context: nil].size;
                
                comment.cellHeight = HOME_TBCELL_DEFAULT_HEIGHT + size.height;
                
                comment.createdAt = object.createdAt.timeAgoSinceNow;
                
                [commentsArray addObject:comment];
            }
            
            [self refreshTable];
            
            [refreshControl endRefreshing];
            
        } else {
            
            [refreshControl endRefreshing];
        }
    }];
}

- (void) refreshTable {
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void) addRefreshButton {
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
            
            if (!refreshControl) {
                
                refreshControl = [[UIRefreshControl alloc] init];
                
                [refreshControl addTarget:self action:@selector(retrieveComments) forControlEvents:UIControlEventValueChanged];
                
                [self.tableView addSubview:refreshControl];
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return commentsArray.count;
}

- (UITableViewCell*) tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CommentsTableViewCell *cell;
    
    if (!cell){
        
        cell = [[CommentsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        cell.comment = [commentsArray objectAtIndex:indexPath.row];
        
        [cell createLabels];
        [cell setLabels];
    }
    
    // Cells must inherit the table view's transform
    // This is very important, since the main table view may be inverted
    cell.transform = self.tableView.transform;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Comment *comment = [commentsArray objectAtIndex:indexPath.row];
    
    return comment.cellHeight;
}

- (void) tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [table deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) tableView:(UITableView *)table moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    [table deselectRowAtIndexPath:sourceIndexPath animated:NO];
}

- (void) shareButtonClicked {
    
    SLComposeViewController *twitter = [SLComposeViewController
                                        composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [twitter setInitialText:[NSString stringWithFormat:@"\"%@\", posted by Anonymous (Mumble App)",mumble.content]];
    
    [self presentViewController:twitter animated:true completion:nil];
}

- (void) didPressRightButton:(id)sender {
    
    [self postComment];
    
    [super didPressRightButton:sender];
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    
    // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
    [self.textView refreshFirstResponder];
}

- (void) postComment {
    
    PFObject *comment = [PFObject objectWithClassName:COMMENTS_DATA_CLASS];
    
    [comment setObject:self.textView.text forKey:COMMENTS_DATA_CONTENT];
    
    [comment setObject:mumble.objectId forKey:COMMENTS_MUMBLE_ID];
    
    [comment setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USERID] forKey:COMMENTS_USER];
    
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [self retrieveComments];
        
        [self.textView resignFirstResponder];
        
        [self addMumbleCommentCount];
        
        [self pushToUser];
    }];
}

- (void) pushToUser {
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:USERID] isEqualToString:mumble.userID]) {
        
        PFPush *push = [[PFPush alloc] init];
        [push setChannel:[NSString stringWithFormat:@"%@%@", USER_PREFIX, mumble.userID]];
        [push setMessage:MUMBLE_COMMENT_PUSH];
        [push sendPushInBackground];
    }
}

- (void) addMumbleCommentCount {
    
    PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
    
    [query getObjectInBackgroundWithId:mumble.objectId block:^(PFObject *mumblePFObject, NSError *error) {
        
        [mumblePFObject setObject:[NSNumber numberWithInt:commentsArray.count] forKey:MUMBLE_DATA_COMMENTS];
        [mumblePFObject saveInBackground];
    }];
}

- (void)didCancelTextEditing:(id)sender
{
    // Notifies the view controller when tapped on the left "Cancel" button
    
    [super didCancelTextEditing:sender];
}

@end
