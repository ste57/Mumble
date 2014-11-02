//
//  HomeCustomTBCell.m
//  Mumble
//
//  Created by Stephen Sowole on 18/10/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import "HomeCustomTBCell.h"
#import "Config.h"

@implementation HomeCustomTBCell

@synthesize mumble;

- (void) createLabels {
    
    double overallOpacity = 0.75;
    double timeOpacity = 0.75;
    
    UITextView *contentTextView = [[UITextView alloc] init];
    contentTextView.textAlignment = NSTextAlignmentLeft;
    contentTextView.textColor = [UIColor blackColor];
    contentTextView.editable = NO;
    contentTextView.selectable = NO;
    contentTextView.scrollEnabled = NO;
    
    NSString *text = [NSString stringWithFormat:@"%@ %@", mumble.content, mumble.msgLocation];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:text];
    
    NSArray *words = [text componentsSeparatedByString:@" "];
    
    for (NSString *word in words) {
        
        if ([word hasPrefix:@"@"]) {
            
            NSRange range = [text rangeOfString:word];
            [string addAttribute:NSForegroundColorAttributeName value:NAV_BAR_COLOUR range:range];
        }
    }
    
    [contentTextView setAttributedText:string];

    contentTextView.font = MUMBLE_CONTENT_TEXT_FONT;

    [contentTextView setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.contentView addSubview:contentTextView];
    
    
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

    
    UIImageView *heartImg = [[UIImageView alloc] init];
    heartImg.image = [UIImage imageNamed:@"heart"];
    [heartImg setTranslatesAutoresizingMaskIntoConstraints:false];
    heartImg.alpha = overallOpacity;
    [self.contentView addSubview:heartImg];
     
    
    UILabel *heartLabel = [[UILabel alloc] init];
    heartLabel.textAlignment = NSTextAlignmentLeft;
    heartLabel.text = [NSString stringWithFormat:@"%i", (int)mumble.likes];
    heartLabel.font = HOME_TIME_FONT;
    heartLabel.textColor = MUMBLE_HOME_OPTIONS_ICON_COLOUR;
    heartLabel.alpha = overallOpacity;
    [heartLabel setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.contentView addSubview:heartLabel];
    
    
    UIImageView *commentImg = [[UIImageView alloc] init];
    commentImg.image = [UIImage imageNamed:@"commentIcon"];
    [commentImg setTranslatesAutoresizingMaskIntoConstraints:false];
    commentImg.alpha = overallOpacity;
    [self.contentView addSubview:commentImg];
    
    UILabel *commentsLabel = [[UILabel alloc] init];
    commentsLabel.textAlignment = NSTextAlignmentLeft;
    commentsLabel.text = [NSString stringWithFormat:@"%i", mumble.comments];
    commentsLabel.font = HOME_TIME_FONT;
    commentsLabel.textColor = MUMBLE_HOME_OPTIONS_ICON_COLOUR;
    commentsLabel.alpha = overallOpacity;
    [commentsLabel setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.contentView addSubview:commentsLabel];
    
    if (mumble.comments < 1) {
        
        //commentsLabel.alpha = 0;
        //commentImg.alpha = 0;
    }

    NSDictionary *views = @{@"content": contentTextView,
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

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:heartLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:12.0]];

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
}

@end
