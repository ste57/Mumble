//
//  HomeCustomTBCell.m
//  Mumble
//
//  Created by Stephen Sowole on 18/10/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import "HomeCustomTBCell.h"
#import "UIButton+Extensions.h"
#import "Config.h"
#import <Parse/Parse.h>
#import "STTweetLabel.h"

@implementation HomeCustomTBCell {
    
    UIButton *heartImg, *commentImg;
    NSMutableArray *likedMumbles;
    UILabel *heartLabel, *commentsLabel;
}

@synthesize mumble;

- (void) retrieveLikedMumbles {
    
    likedMumbles = [[NSMutableArray alloc] init];
    
    NSMutableArray *tempArray = (NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:MUMBLES_LIKED_BY_USER];
    
    for (NSString *_id in tempArray) {
        
        [likedMumbles addObject:_id];
    }
}

- (void) createLabels {
    
    [self retrieveLikedMumbles];
    
    double overallOpacity = 0.75;
    double timeOpacity = 0.75;
    
    STTweetLabel *contentLabel = [[STTweetLabel alloc] init];
    [contentLabel setText:mumble.content];
    [contentLabel setTextAlignment:NSTextAlignmentLeft];
    [contentLabel setTranslatesAutoresizingMaskIntoConstraints:false];
    
    [contentLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TAG_PRESSED object:string];
    }];
    
    [self.contentView addSubview:contentLabel];
    
    
    UIImageView *timeImg = [[UIImageView alloc] init];
    timeImg.image = [UIImage imageNamed:@"clock"];
    timeImg.alpha = timeOpacity;
    [timeImg setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.contentView addSubview:timeImg];
    
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.text = mumble.createdAt;
    timeLabel.font = HOME_TIME_FONT;
    timeLabel.textColor = MUMBLE_HOME_OPTIONS_ICON_COLOUR;
    timeLabel.alpha = timeOpacity;
    [timeLabel setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.contentView addSubview:timeLabel];
    
    
    heartImg = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [heartImg addTarget:self action:@selector(heartBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [heartImg setBackgroundImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
    [heartImg setBackgroundImage:[UIImage imageNamed:@"heartLiked"] forState:UIControlStateSelected];
    [heartImg setTranslatesAutoresizingMaskIntoConstraints:false];
    heartImg.adjustsImageWhenHighlighted = NO;
    [heartImg setTintColor:[UIColor whiteColor]];
    heartImg.alpha = overallOpacity;
    [heartImg setHitTestEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];
    [self.contentView addSubview:heartImg];
    
    if ([likedMumbles containsObject:mumble.objectId] && mumble.likes > 0) {
        
        heartImg.selected = YES;
        
    } else if (mumble.likes <= 0) {
        
        [likedMumbles removeObject:mumble.objectId];
    }
    
    heartLabel = [[UILabel alloc] init];
    heartLabel.textAlignment = NSTextAlignmentLeft;
    heartLabel.text = [self abbreviateNumber:mumble.likes];
    heartLabel.font = HOME_TIME_FONT;
    heartLabel.textColor = MUMBLE_HOME_OPTIONS_ICON_COLOUR;
    heartLabel.alpha = overallOpacity;
    [heartLabel setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.contentView addSubview:heartLabel];
    
    
    commentImg = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [commentImg addTarget:self action:@selector(commentBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [commentImg setBackgroundImage:[UIImage imageNamed:@"commentIcon"] forState:UIControlStateNormal];
    [commentImg setTranslatesAutoresizingMaskIntoConstraints:false];
    commentImg.adjustsImageWhenHighlighted = NO;
    [commentImg setTintColor:[UIColor whiteColor]];
    commentImg.alpha = overallOpacity;
    [commentImg setHitTestEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];
    [self.contentView addSubview:commentImg];
    
    
    commentsLabel = [[UILabel alloc] init];
    commentsLabel.textAlignment = NSTextAlignmentLeft;
    commentsLabel.text = [self abbreviateNumber:mumble.comments];
    commentsLabel.font = HOME_TIME_FONT;
    commentsLabel.textColor = MUMBLE_HOME_OPTIONS_ICON_COLOUR;
    commentsLabel.alpha = overallOpacity;
    [commentsLabel setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.contentView addSubview:commentsLabel];
    
    if (mumble.comments < 1) {
        
        //commentsLabel.alpha = 0;
        //commentImg.alpha = 0;
    }
    
    NSDictionary *views = @{@"content": contentLabel,
                            @"timeImg": timeImg,
                            @"timeLabel": timeLabel,
                            @"heartImg": heartImg,
                            @"heartLabel": heartLabel,
                            @"commentImg": commentImg,
                            @"commentsLabel": commentsLabel };
    
    
    //NSArray *x = [NSLayoutConstraint constraintsWithVisualFormat:@"|-(margin)-[content]-(margin)-|" options:0 metrics:nil views:views];
    
    // ImageView Constraints
    
    [timeImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[timeImg(8)]" options:0 metrics:nil views:views]];
    [timeImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[timeImg(8)]" options:0 metrics:nil views:views]];
    
    [heartImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[heartImg(15)]" options:0 metrics:nil views:views]];
    [heartImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[heartImg(15)]" options:0 metrics:nil views:views]];
    
    [commentImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[commentImg(16)]" options:0 metrics:nil views:views]];
    [commentImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[commentImg(16)]" options:0 metrics:nil views:views]];
    
    
    // Horizontal Constraints
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[content]-15-|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[timeImg]-5-[timeLabel]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[commentImg]-5-[commentsLabel]-28-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:heartImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-5.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:heartLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:8.0]];
    
    // Vertical Constriants
    
    int optionEndSpace = 10;
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                      [NSString stringWithFormat:@"V:|-10-[content][timeLabel]-%i-|", optionEndSpace] options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                      [NSString stringWithFormat:@"V:|-10-[content][commentsLabel]-%i-|", optionEndSpace] options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                      [NSString stringWithFormat:@"V:|-10-[content][heartImg]-%i-|", optionEndSpace] options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                      [NSString stringWithFormat:@"V:|-10-[content][heartLabel]-%i-|", optionEndSpace] options:0 metrics:nil views:views]];
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            
            heartImg.hidden = YES;
            heartLabel.hidden = YES;
            commentImg.hidden = YES;
            commentsLabel.hidden = YES;
            
        }
    }
}

- (void) commentBtnPressed {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:COMMENTS_PRESSED object:mumble];
}

- (void) heartBtnPressed {
    
    [self retrieveLikedMumbles];
    
    if (heartImg.selected) {
        
        [self unLikeMumble];
        
    } else {
        
        [self likeMumble];
    }
}

- (void) likeMumble {
    
    heartImg.selected = YES;
    
    if (![likedMumbles containsObject:mumble.objectId]) {
        
        mumble.likes++;
        
        PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
        
        [query getObjectInBackgroundWithId:mumble.objectId block:^(PFObject *mumblePFObject, NSError *error) {
            
            [mumblePFObject incrementKey:MUMBLE_DATA_LIKES byAmount:[NSNumber numberWithInt:1]];
            
            [mumblePFObject saveEventually:^(BOOL succeeded, NSError *error) {
                
                if (mumble.likes == 1) {
                    
                    PFPush *push = [[PFPush alloc] init];
                    [push setChannel:[NSString stringWithFormat:@"%@%@", USER_PREFIX, mumble.userID]];
                    [push setMessage:MUMBLE_1_LIKE];
                    [push sendPushInBackground];
                    
                } else if (mumble.likes == 5) {
                    
                    PFPush *push = [[PFPush alloc] init];
                    [push setChannel:[NSString stringWithFormat:@"%@%@", USER_PREFIX, mumble.userID]];
                    [push setMessage:MUMBLE_5_LIKE];
                    [push sendPushInBackground];
                    
                } else if (mumble.likes == 10) {
                    
                    PFPush *push = [[PFPush alloc] init];
                    [push setChannel:[NSString stringWithFormat:@"%@%@", USER_PREFIX, mumble.userID]];
                    [push setMessage:MUMBLE_10_LIKE];
                    [push sendPushInBackground];
                }
                
            }];
            
        }];
        
        [likedMumbles addObject:mumble.objectId];
        
        [[NSUserDefaults standardUserDefaults] setObject:likedMumbles forKey:MUMBLES_LIKED_BY_USER];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        heartLabel.text = [self abbreviateNumber:mumble.likes];
    }
}

- (void) unLikeMumble {
    
    heartImg.selected = NO;
    
    PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
    
    [query getObjectInBackgroundWithId:mumble.objectId block:^(PFObject *mumblePFObject, NSError *error) {
        
        if (mumble.likes > 0) {
            
            [mumblePFObject incrementKey:MUMBLE_DATA_LIKES byAmount:[NSNumber numberWithInt:-1]];
            [mumblePFObject saveEventually];
        }
    }];
    
    [likedMumbles removeObject:mumble.objectId];
    
    [[NSUserDefaults standardUserDefaults] setObject:likedMumbles forKey:MUMBLES_LIKED_BY_USER];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    mumble.likes--;
    
    heartLabel.text = [self abbreviateNumber:mumble.likes];
}

- (NSString *) abbreviateNumber:(long)num {
    
    NSString *abbrevNum;
    float number = (float)num;
    
    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        NSArray *abbrev = @[@"K", @"M", @"B"];
        
        for (long i = abbrev.count - 1; i >= 0; i--) {
            
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);
            
            if(size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [self floatToString:number];
                
                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
            }
            
        }
    } else {
        
        // Numbers like: 999 returns 999 instead of NULL
        abbrevNum = [NSString stringWithFormat:@"%d", (int)number];
    }
    
    return abbrevNum;
}

- (NSString *) floatToString:(float) val {
    
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
        
        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if(c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
        }
    }
    
    return ret;
}

@end
