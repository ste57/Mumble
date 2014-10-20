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
    
    UILabel *msgLocation = [[UILabel alloc] init];
    msgLocation.textAlignment = NSTextAlignmentLeft;
    msgLocation.frame = CGRectMake(0, 0, self.frame.size.width - CELL_PADDING*2, HOME_TBCELL_DEFAULT_HEIGHT/2);
    msgLocation.center = CGPointMake(self.frame.size.width/2, CELL_PADDING);
    msgLocation.text = mumble.msgLocation;
    msgLocation.font = TIME_LOCATION_FONT;
    msgLocation.textColor = MAIN_TEXT_FONT_COLOUR;
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.frame = CGRectMake(CELL_PADDING*2, msgLocation.center.y/2, self.frame.size.width - CELL_PADDING*4, mumble.cellHeight);
    contentLabel.text = mumble.content;
    contentLabel.numberOfLines = 5;
    contentLabel.font = MUMBLE_CONTENT_TEXT_FONT;
    
    
    UIImageView *img = [[UIImageView alloc] init];
    img.image = [UIImage imageNamed:@"clock"];
    img.layer.anchorPoint = CGPointMake(0, 0);
    img.frame = CGRectMake(self.frame.size.width - CELL_PADDING*3.15, msgLocation.center.y - img.image.size.height/4, 8, 8);
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.frame = CGRectMake(img.center.x + img.image.size.width/1.5, 0, 40, HOME_TBCELL_DEFAULT_HEIGHT/2);
    timeLabel.text = mumble.createdAt;
    timeLabel.font = TIME_LOCATION_FONT;
    timeLabel.textColor = MAIN_TEXT_FONT_COLOUR;
    
    [self.contentView addSubview:img];
    [self.contentView addSubview:contentLabel];
    [self.contentView addSubview:msgLocation];
    [self.contentView addSubview:timeLabel];
}

@end
