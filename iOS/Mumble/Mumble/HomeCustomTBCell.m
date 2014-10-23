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
    
    UITextView *contentLabel = [[UITextView alloc] init];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.frame = CGRectMake(CELL_PADDING, CELL_PADDING/2, [[UIScreen mainScreen] bounds].size.width - CELL_PADDING*2, mumble.cellHeight);
    contentLabel.editable = NO;
    contentLabel.selectable = NO;
    
    NSString *text = [NSString stringWithFormat:@"%@ %@", mumble.content, mumble.msgLocation];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:text];
    
    NSArray *words = [text componentsSeparatedByString:@" "];
    
    for (NSString *word in words) {
        
        if ([word hasPrefix:@"@"]) {
            
            NSRange range = [text rangeOfString:word];
            [string addAttribute:NSForegroundColorAttributeName value:NAV_BAR_COLOUR range:range];
        }
    }
    
    [contentLabel setAttributedText:string];

    contentLabel.font = MUMBLE_CONTENT_TEXT_FONT;
    
    [self.contentView addSubview:contentLabel];
    
    
    UIImageView *timeImg = [[UIImageView alloc] init];
    timeImg.image = [UIImage imageNamed:@"clock"];
    timeImg.layer.anchorPoint = CGPointMake(0, -1.0);
    timeImg.frame = CGRectMake(CELL_PADDING + timeImg.image.size.width/2, mumble.cellHeight - CELL_PADDING*1.50, 8, 8);
    
    [self.contentView addSubview:timeImg];
    
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.frame = CGRectMake(timeImg.center.x + timeImg.image.size.width, timeImg.center.y, 100, HOME_TBCELL_DEFAULT_HEIGHT/2);
    timeLabel.text = mumble.createdAt;
    timeLabel.font = HOME_TIME_FONT;
    timeLabel.textColor = MUMBLE_HOME_OPTIONS_ICON_COLOUR;
    
    [self.contentView addSubview:timeLabel];

    
    UIImageView *heartImg = [[UIImageView alloc] init];
    heartImg.image = [UIImage imageNamed:@"heart"];
    heartImg.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - heartImg.image.size.width/2, timeImg.center.y + heartImg.image.size.height/6, 15, 15);
    
    [self.contentView addSubview:heartImg];
    
    
    UILabel *heartLabel = [[UILabel alloc] init];
    heartLabel.textAlignment = NSTextAlignmentLeft;
    heartLabel.frame = CGRectMake(heartImg.center.x + heartImg.image.size.width/2, timeImg.center.y, 100, HOME_TBCELL_DEFAULT_HEIGHT/2);
    heartLabel.text = @"10";
    heartLabel.font = HOME_TIME_FONT;
    heartLabel.textColor = MUMBLE_HOME_OPTIONS_ICON_COLOUR;
    
    [self.contentView addSubview:heartLabel];
    
    
    UIImageView *commentImg = [[UIImageView alloc] init];
    commentImg.image = [UIImage imageNamed:@"commentIcon"];
    commentImg.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 50, timeImg.center.y + heartImg.image.size.height/6, 16, 16);
    
    [self.contentView addSubview:commentImg];
    
    
    UILabel *commentsLabel = [[UILabel alloc] init];
    commentsLabel.textAlignment = NSTextAlignmentLeft;
    commentsLabel.frame = CGRectMake(commentImg.frame.origin.x + 20, timeImg.center.y, 100, HOME_TBCELL_DEFAULT_HEIGHT/2);
    commentsLabel.text = @"5";
    commentsLabel.font = HOME_TIME_FONT;
    commentsLabel.textColor = MUMBLE_HOME_OPTIONS_ICON_COLOUR;
    
    [self.contentView addSubview:commentsLabel];
}

@end
