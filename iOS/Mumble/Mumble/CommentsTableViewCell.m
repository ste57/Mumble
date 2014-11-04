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

@interface CommentsTableViewCell ()

@property (nonatomic) UITextView *commentView;
@property (nonatomic) UIImageView *timeImg;
@property (nonatomic) UILabel *timeLabel;
@property (nonatomic) UIButton *heartImg;
@property (nonatomic) UILabel *heartLabel;

@end

@implementation CommentsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setSeparatorInset:UIEdgeInsetsZero];

        self.commentView = [[UITextView alloc] initWithFrame:CGRectMake(20, 15, 270, 1000)];
        [self.commentView setEditable:NO];
        [self.commentView setSelectable:YES];
        [self.commentView setScrollEnabled:NO];
        [self.commentView setText:@"Hello, This is a comment"];
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
        self.timeLabel.text = @"Yesterday";
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
        [self.heartImg setTintColor:[UIColor whiteColor]];
        self.heartImg.alpha = 0.75;
        [self.heartImg setHitTestEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];
        [self.contentView addSubview:self.heartImg];


        self.heartLabel = [[UILabel alloc] init];
        self.heartLabel.textAlignment = NSTextAlignmentLeft;
        self.heartLabel.text = @"10";
        self.heartLabel.font = HOME_TIME_FONT;
        self.heartLabel.textColor = MUMBLE_HOME_OPTIONS_ICON_COLOUR;
        self.heartLabel.alpha = 0.75;
        [self.heartLabel setTranslatesAutoresizingMaskIntoConstraints:false];
        [self.contentView addSubview:self.heartLabel];

        [self setNeedsUpdateConstraints];
    }
    
    return self;
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

@end
