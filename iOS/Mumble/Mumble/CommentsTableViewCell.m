//
//  CommentsTableViewCell.m
//  Mumble
//
//  Created by Stephen Sowole on 03/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import "Config.h"
#import "UIButton+Extensions.h"
#import "CommentsTableViewCell.h"
#import <Parse/Parse.h>

@interface CommentsTableViewCell ()

@property (nonatomic) UITextView *commentView;
@property (nonatomic) UIImageView *timeImg;
@property (nonatomic) UILabel *timeLabel;
@property (nonatomic) UIButton *heartImg;
@property (nonatomic) UILabel *heartLabel;

@end

@implementation CommentsTableViewCell {
    
    NSMutableArray *likedComments;
}

@synthesize comment;

- (void) createLabels {
    
    [self retrieveLikedComments];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self setSeparatorInset:UIEdgeInsetsZero];
    
    self.commentView = [[UITextView alloc] initWithFrame:CGRectMake(20, 15, 270, 1000)];
    [self.commentView setEditable:NO];
    [self.commentView setSelectable:YES];
    [self.commentView setScrollEnabled:NO];
    [self.commentView setFont:MUMBLE_CONTENT_TEXT_FONT];
    [self.commentView setTextAlignment:NSTextAlignmentJustified];
    [self.commentView setDataDetectorTypes:UIDataDetectorTypeLink];
    [self.commentView setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.contentView addSubview:self.commentView];
    
    self.timeImg = [[UIImageView alloc] init];
    self.timeImg.image = [UIImage imageNamed:@"clock"];
    self.timeImg.alpha = 0.75;
    [self.timeImg setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.contentView addSubview:self.timeImg];
    
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textAlignment = NSTextAlignmentLeft;
    self.timeLabel.font = HOME_TIME_FONT;
    self.timeLabel.textColor = MUMBLE_HOME_OPTIONS_ICON_COLOUR;
    self.timeLabel.alpha = 0.75;
    [self.timeLabel setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.contentView addSubview:self.timeLabel];
    
    
    self.heartImg = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.heartImg addTarget:self action:@selector(heartBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.heartImg setBackgroundImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
    [self.heartImg setBackgroundImage:[UIImage imageNamed:@"heartLiked"] forState:UIControlStateSelected];
    [self.heartImg setTranslatesAutoresizingMaskIntoConstraints:false];
    self.heartImg.adjustsImageWhenHighlighted = NO;
    [self.heartImg setTintColor:[UIColor clearColor]];
    self.heartImg.alpha = 0.75;
    [self.heartImg setHitTestEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];
    [self.contentView addSubview:self.heartImg];
    
    if ([likedComments containsObject:comment.objectId] && comment.likes > 0) {
        
        self.heartImg.selected = YES;
        
    } else if (comment.likes <= 0) {
        
        [likedComments removeObject:comment.objectId];
    }
    
    
    self.heartLabel = [[UILabel alloc] init];
    self.heartLabel.textAlignment = NSTextAlignmentLeft;
    
    self.heartLabel.font = HOME_TIME_FONT;
    self.heartLabel.textColor = MUMBLE_HOME_OPTIONS_ICON_COLOUR;
    self.heartLabel.alpha = 0.75;
    [self.heartLabel setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.contentView addSubview:self.heartLabel];
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    
    NSDictionary *views = @{@"content": self.commentView,
                            @"timeImg": self.timeImg,
                            @"timeLabel": self.timeLabel,
                            @"heartImg": self.heartImg,
                            @"heartLabel": self.heartLabel };
    
    // ImageView Constraints
    
    [self.timeImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[timeImg(8)]" options:0 metrics:nil views:views]];
    [self.timeImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[timeImg(8)]" options:0 metrics:nil views:views]];
    
    [self.heartImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[heartImg(15)]" options:0 metrics:nil views:views]];
    [self.heartImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[heartImg(15)]" options:0 metrics:nil views:views]];
    
    // Horizontal Constraints
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[content]-15-|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[timeImg]-5-[timeLabel]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.heartImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-5.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.heartLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:8.0]];
    
    // Vertical Constriants
    
    NSDictionary *metrics = @{@"optionEndSpace": @10};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[content][timeLabel]-(optionEndSpace)-|" options:0 metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[content][heartImg]-(optionEndSpace)-|" options:0 metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[content][heartLabel]-(optionEndSpace)-|" options:0 metrics:metrics views:views]];
    
    [super updateConstraints];
}

- (void) retrieveLikedComments {
    
    likedComments = [[NSMutableArray alloc] init];
    
    NSMutableArray *tempArray = (NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:COMMENTS_LIKED_BY_USER];
    
    for (NSString *_id in tempArray) {
        
        [likedComments addObject:_id];
    }
}

- (void) heartBtnPressed {
    
    [self retrieveLikedComments];
    
    if (self.heartImg.selected) {
        
        [self unLikeComment];
        
    } else {
        
        [self likeComment];
    }
}

- (void) likeComment {
    
    self.heartImg.selected = YES;
    
    if (![likedComments containsObject:comment.objectId]) {
        
        comment.likes++;
        
        PFQuery *query = [PFQuery queryWithClassName:COMMENTS_DATA_CLASS];
        
        [query getObjectInBackgroundWithId:comment.objectId block:^(PFObject *mumblePFObject, NSError *error) {
            
            [mumblePFObject incrementKey:COMMENTS_DATA_LIKES byAmount:[NSNumber numberWithInt:1]];
            
            [mumblePFObject saveEventually];
            
        }];
        
        [likedComments addObject:comment.objectId];
        
        [[NSUserDefaults standardUserDefaults] setObject:likedComments forKey:COMMENTS_LIKED_BY_USER];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.heartLabel.text = [self abbreviateNumber:comment.likes];
    }
}

- (void) unLikeComment {
    
    self.heartImg.selected = NO;
    
    PFQuery *query = [PFQuery queryWithClassName:COMMENTS_DATA_CLASS];
    
    [query getObjectInBackgroundWithId:comment.objectId block:^(PFObject *mumblePFObject, NSError *error) {
        
        if (comment.likes > 0) {
            
            [mumblePFObject incrementKey:COMMENTS_DATA_LIKES byAmount:[NSNumber numberWithInt:-1]];
            [mumblePFObject saveEventually];
        }
    }];
    
    [likedComments removeObject:comment.objectId];
    
    [[NSUserDefaults standardUserDefaults] setObject:likedComments forKey:COMMENTS_LIKED_BY_USER];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    comment.likes--;
    
    self.heartLabel.text = [self abbreviateNumber:comment.likes];
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

- (void) setLabels {
    
    [self.commentView setText:comment.content];
    self.heartLabel.text = [NSString stringWithFormat:@"%lu", comment.likes];
    self.timeLabel.text = comment.createdAt;
}

@end
