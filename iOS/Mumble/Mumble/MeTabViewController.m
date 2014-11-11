//
//  MeTabViewController.m
//  Mumble
//
//  Created by Stephen Sowole on 08/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import "MeTabViewController.h"
#import "Config.h"
#import <Parse/Parse.h>
#import "MyMumblesViewController.h"
#import "LikedMumblesViewController.h"

@implementation MeTabViewController {
    
    long likes;
    NSString *userID;
    
    UIView *viewWithPadding;
    UILabel *label;
    UIView *topHeader;
}

CGFloat screenWidth;
CGFloat screenHeight;


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = ME_TAB_TITLE;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self layOutTop];
    
    [self layOutTableView];
    
    [self removeBackButtonText];
}

- (void) removeBackButtonText {
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
}

- (void) viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = YES;
    [self retrieveLikes];
    self.screenName = @"Me";
}

- (void) retrieveLikes {
    
    userID = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:USERID];
    
    PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
    
    [query whereKey:MUMBLE_DATA_USER equalTo:userID];
    
    [query selectKeys:@[MUMBLE_DATA_LIKES]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        long tempLikes = 0;
        
        for (PFObject *object in objects) {
            
            tempLikes += [object[MUMBLE_DATA_LIKES] longValue];
        }
        
        likes = tempLikes;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLong:likes] forKey:LIKES];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [label removeFromSuperview];
        [viewWithPadding removeFromSuperview];
        [topHeader removeFromSuperview];
        
        [self.tableView removeFromSuperview];
        
        [self layOutTop];
        
        [self layOutTableView];
    }];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void) layOutTop {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    screenWidth = screenRect.size.width;
    
    screenHeight = screenRect.size.height;
    
    topHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 200)];
    [topHeader setBackgroundColor:NAV_BAR_HEADER_COLOUR];
    [self.view addSubview:topHeader];
    
    viewWithPadding = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2-50, 45, 100, 100)];
    [viewWithPadding setBackgroundColor: NAV_BAR_HEADER_COLOUR];
    [viewWithPadding.layer setCornerRadius:50];
    [viewWithPadding.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [viewWithPadding.layer setBorderWidth:4];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 20, 50, 50)];
    [imageView setImage:[UIImage imageNamed:@"meMumble"]];
    [viewWithPadding addSubview:imageView];
    
    label = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2-50, 150, 100, 50)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont fontWithName:@"fontello" size:15]];
    [label setNumberOfLines:0];
    
    UIFont *font1 = [UIFont fontWithName:@"fontello" size:15];
    NSDictionary *arialDict = @{NSFontAttributeName: font1,
                                 NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:@"\uE801  " attributes: arialDict];
    
    UIFont *font3 = [UIFont fontWithName:MUMBLE_FONT_NAME size:17];
    NSDictionary *arialDict3 = @{NSFontAttributeName: font3,
                                 NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    likes = [[[NSUserDefaults standardUserDefaults] objectForKey:LIKES] longValue];
    
    NSMutableAttributedString *aAttrString3 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu",likes] attributes: arialDict3];
    
    [aAttrString1 appendAttributedString:aAttrString3];
    
    label.attributedText = aAttrString1;
    
    [topHeader addSubview:label];
    
    [topHeader addSubview:viewWithPadding];
    
}

- (void) layOutTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, screenWidth, 120)];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setScrollEnabled:NO];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.view addSubview:self.tableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    if (cell == nil) {
        
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = MUMBLE_CONTENT_TEXT_FONT;
        
        switch ([indexPath row]) {
                
            case 0:
                cell.textLabel.text = @"My Mumbles";
                break;
            case 1:
                cell.textLabel.text = @"Mumbles I've Liked";
                break;
            default:
                break;
        }
        
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //[cell.textLabel setFont:[UIFont systemFontOfSize:15]];
    //[cell.textLabel setTextColor:[UIColor colorWithRed:0.204 green:0.22 blue:0.22 alpha:1]];
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    if ([indexPath row] == 0) {
        
        self.navigationController.navigationBarHidden = NO;
        
        MyMumblesViewController *mumbleVC = [[MyMumblesViewController alloc] init];
        [self.navigationController pushViewController:mumbleVC animated:YES];
        
    } else {
        
        self.navigationController.navigationBarHidden = NO;
        
        LikedMumblesViewController *mumbleVC = [[LikedMumblesViewController alloc] init];
        [self.navigationController pushViewController:mumbleVC animated:YES];
    }
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
