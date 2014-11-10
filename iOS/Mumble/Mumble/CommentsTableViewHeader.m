//
//  CommentTableViewHeader.m
//  Mumble
//
//  Created by Tosin Afolabi on 05/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import "Config.h"
#import "CommentsTableViewHeader.h"
#import "UIButton+Extensions.h"
#import "NSDate+DateTools.h"
#import <Parse/Parse.h>

@implementation CommentsTableViewHeader {
    
    NSMutableArray *likedMumbles;
}

@synthesize mumble;

- (void) createLabels {
        
        [self retrieveLikedMumbles];
        
        UIImageView *timeImg = [[UIImageView alloc] init];
        timeImg.image = [UIImage imageNamed:@"clock"];
        timeImg.alpha = 0.7;
        [timeImg setTranslatesAutoresizingMaskIntoConstraints:false];
        
        self.timeLabel = [UILabel new];
        self.timeLabel.text = mumble.createdAt;
        self.timeLabel.font = HOME_TIME_FONT;
        self.timeLabel.textColor = [UIColor colorWithRed:0.667 green:0.667 blue:0.667 alpha:1];
        [self.timeLabel setTranslatesAutoresizingMaskIntoConstraints:false];
        //[self addSubview:self.timeLabel];
        
        
        self.postLabel = [UITextView new];
        self.postLabel.text = mumble.content;
        self.postLabel.font = MUMBLE_CONTENT_TEXT_FONT;
        self.postLabel.scrollEnabled = NO;
        self.postLabel.selectable = NO;
        self.postLabel.textContainerInset = UIEdgeInsetsMake(0,15,0,15)  ;
        [self.postLabel setTranslatesAutoresizingMaskIntoConstraints:false];
        [self addSubview:self.postLabel];
        
        UIImageView *shareImg = [[UIImageView alloc] init];
        shareImg.image = [UIImage imageNamed:@"share"];
        //shareImg.alpha = 0.7;
        [shareImg setTranslatesAutoresizingMaskIntoConstraints:false];
        
        self.shareLabel = [UILabel new];
        self.shareLabel.text = @"share";
        self.shareLabel.font = HOME_TIME_FONT;
        self.shareLabel.textColor = [UIColor colorWithRed:0.667 green:0.667 blue:0.667 alpha:1];
        [self.shareLabel setTranslatesAutoresizingMaskIntoConstraints:false];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareOnTwitter)];
        
        [self.shareLabel addGestureRecognizer:tap];
        self.shareLabel.userInteractionEnabled = YES;
        
        
        
        
        UIView *greyBackgroundView = [UIView new];
        greyBackgroundView.backgroundColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1];
        [greyBackgroundView setTranslatesAutoresizingMaskIntoConstraints:false];
        [self addSubview:greyBackgroundView];
        //greyBackgroundView.alpha = 0.0;
        
        [greyBackgroundView addSubview:timeImg];
        [greyBackgroundView addSubview:self.timeLabel];
        
        [greyBackgroundView addSubview:shareImg];
        [greyBackgroundView addSubview:self.shareLabel];
        
        self.heartImg = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.heartImg addTarget:self action:@selector(heartBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.heartImg setBackgroundImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
        [self.heartImg setBackgroundImage:[UIImage imageNamed:@"heartLiked"] forState:UIControlStateSelected];
        [self.heartImg setTranslatesAutoresizingMaskIntoConstraints:false];
        self.heartImg.adjustsImageWhenHighlighted = NO;
        [self.heartImg setTintColor:[UIColor clearColor]];
        //self.heartImg.alpha = 0.75;
        [self.heartImg setHitTestEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];
        
        if ([likedMumbles containsObject:mumble.objectId] && mumble.likes > 0) {
            
            self.heartImg.selected = YES;
            
        } else if (mumble.likes <= 0) {
            
            [likedMumbles removeObject:mumble.objectId];
        }
        
        [greyBackgroundView addSubview:self.heartImg];
        
        
        self.heartLabel = [[UILabel alloc] init];
        self.heartLabel.textAlignment = NSTextAlignmentLeft;
        self.heartLabel.text = @"10 likes";
        self.heartLabel.font = HOME_TIME_FONT;
        self.heartLabel.textColor = [UIColor colorWithRed:0.667 green:0.667 blue:0.667 alpha:1];
        //self.heartLabel.alpha = 0.75;
        [self.heartLabel setTranslatesAutoresizingMaskIntoConstraints:false];
        [greyBackgroundView addSubview:self.heartLabel];
        
        NSDictionary *views = @{
                                @"timeImg": timeImg,
                                @"timeLabel": self.timeLabel,
                                @"postLabel": self.postLabel,
                                @"gbv": greyBackgroundView,
                                @"heartImg": self.heartImg,
                                @"heartLabel": self.heartLabel,
                                @"shareImg": shareImg,
                                @"shareLabel": self.shareLabel
                                };
        
        [greyBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[gbv(40)]" options:0 metrics:nil views:views]];
        
        [timeImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[timeImg(8)]" options:0 metrics:nil views:views]];
        [timeImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[timeImg(8)]" options:0 metrics:nil views:views]];
        
        [shareImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[shareImg(15)]" options:0 metrics:nil views:views]];
        [shareImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[shareImg(15)]" options:0 metrics:nil views:views]];
        
        [self.heartImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[heartImg(15)]" options:0 metrics:nil views:views]];
        [self.heartImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[heartImg(15)]" options:0 metrics:nil views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[postLabel]|" options:0 metrics:nil views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[postLabel]-20-[gbv]" options:0 metrics:nil views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[heartImg]-5-[heartLabel]" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[shareImg]-5-[shareLabel]" options:0 metrics:nil views:views]];
        
        [greyBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[timeImg]-5-[timeLabel]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        
        [greyBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[shareImg]-5-[shareLabel]-24-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[gbv]|" options:0 metrics:nil views:views]];
        
        [greyBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.heartImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:greyBackgroundView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-5.0]];
        
        //[greyBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.heartLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:greyBackgroundView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-15.0]];
        
        [greyBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.heartImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:greyBackgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [greyBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.heartLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:greyBackgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [greyBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:timeImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:greyBackgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [greyBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:greyBackgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [greyBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:shareImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:greyBackgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [greyBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.shareLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:greyBackgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
}

- (void) retrieveLikedMumbles {
    
    likedMumbles = [[NSMutableArray alloc] init];
    
    NSMutableArray *tempArray = (NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:MUMBLES_LIKED_BY_USER];
    
    for (NSString *_id in tempArray) {
        
        [likedMumbles addObject:_id];
    }
}

- (void) heartBtnPressed {
    
    [self retrieveLikedMumbles];
    
    if (self.heartImg.selected) {
        
        [self unLikeMumble];
        
    } else {
        
        [self likeMumble];
    }
}

- (void) likeMumble {
    
    self.heartImg.selected = YES;
    
    if (![likedMumbles containsObject:mumble.objectId]) {
        
        mumble.likes++;
        
        PFQuery *query = [PFQuery queryWithClassName:MUMBLE_DATA_CLASS];
        
        [query getObjectInBackgroundWithId:mumble.objectId block:^(PFObject *mumblePFObject, NSError *error) {
            
            [mumblePFObject incrementKey:MUMBLE_DATA_LIKES byAmount:[NSNumber numberWithInt:1]];
            
            [mumblePFObject saveEventually:^(BOOL succeeded, NSError *error) {
                
                if (![[[NSUserDefaults standardUserDefaults] objectForKey:USERID] isEqualToString:mumble.userID]) {
                    
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
                }
                
            }];
            
        }];
        
        [likedMumbles addObject:mumble.objectId];
        
        [[NSUserDefaults standardUserDefaults] setObject:likedMumbles forKey:MUMBLES_LIKED_BY_USER];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.heartLabel.text = [self abbreviateNumber:mumble.likes];
    }
}

- (void) unLikeMumble {
    
    self.heartImg.selected = NO;
    
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
    
    self.heartLabel.text = [self abbreviateNumber:mumble.likes];
}

- (void)shareOnTwitter {
    
    [self.delegate shareButtonClicked];
    //[self.presentViewController:twitter animated:YES completion:nil];
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

- (void) setLabelNames {
    
    self.timeLabel.text = mumble.shortCreatedAt;
    self.postLabel.text = mumble.content;
    self.heartLabel.text = [NSString stringWithFormat:@"%lu", mumble.likes];
}

@end
