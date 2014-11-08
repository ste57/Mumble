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

@implementation CommentsTableViewHeader

@synthesize mumble;

-(id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];

    if (self) {

        self.locationLabel = [UILabel new];
        self.locationLabel.text = @"@Exchange";
        self.locationLabel.font = HOME_TIME_FONT;
        self.locationLabel.textColor = NAV_BAR_COLOUR;
        [self.locationLabel setTranslatesAutoresizingMaskIntoConstraints:false];
        [self addSubview:self.locationLabel];

        self.timeLabel = [UILabel new];
        self.timeLabel.text = @"2m ago";
        self.timeLabel.font = HOME_TIME_FONT;
        [self.timeLabel setTranslatesAutoresizingMaskIntoConstraints:false];
        [self addSubview:self.timeLabel];

        self.postLabel = [UITextView new];
        self.postLabel.text = @"I was told to never give up on my dreams. Which is why i slept through my 9am";
        self.postLabel.font = MUMBLE_CONTENT_TEXT_FONT;
        self.postLabel.scrollEnabled = NO;
        self.postLabel.textContainerInset = UIEdgeInsetsMake(0,15,0,15)  ;
        [self.postLabel setTranslatesAutoresizingMaskIntoConstraints:false];
        [self addSubview:self.postLabel];


        UIView *greyBackgroundView = [UIView new];
        greyBackgroundView.backgroundColor = [UIColor grayColor];
        [greyBackgroundView setTranslatesAutoresizingMaskIntoConstraints:false];
        [self addSubview:greyBackgroundView];
        //greyBackgroundView.alpha = 0.0;

        self.heartImg = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.heartImg addTarget:self action:@selector(heartBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.heartImg setBackgroundImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
        [self.heartImg setBackgroundImage:[UIImage imageNamed:@"heartLiked"] forState:UIControlStateSelected];
        [self.heartImg setTranslatesAutoresizingMaskIntoConstraints:false];
        self.heartImg.adjustsImageWhenHighlighted = NO;
        [self.heartImg setTintColor:[UIColor whiteColor]];
        self.heartImg.alpha = 0.75;
        [self.heartImg setHitTestEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];
        [greyBackgroundView addSubview:self.heartImg];


        self.heartLabel = [[UILabel alloc] init];
        self.heartLabel.textAlignment = NSTextAlignmentLeft;
        self.heartLabel.text = @"10";
        self.heartLabel.font = HOME_TIME_FONT;
        self.heartLabel.textColor = [UIColor whiteColor];
        self.heartLabel.alpha = 0.75;
        [self.heartLabel setTranslatesAutoresizingMaskIntoConstraints:false];
        [greyBackgroundView addSubview:self.heartLabel];

        NSDictionary *views = @{@"location": self.locationLabel,
                                @"timeLabel": self.timeLabel,
                                @"postLabel": self.postLabel,
                                @"gbv": greyBackgroundView,
                                @"heartImg": self.heartImg,
                                @"heartLabel": self.heartLabel };

        [greyBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[gbv(30)]" options:0 metrics:nil views:views]];

        [self.heartImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[heartImg(15)]" options:0 metrics:nil views:views]];
        [self.heartImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[heartImg(15)]" options:0 metrics:nil views:views]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[location]" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[postLabel]|" options:0 metrics:nil views:views]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[location]-10-[postLabel]-10-[gbv]" options:0 metrics:nil views:views]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[timeLabel]-15-|" options:0 metrics:nil views:views]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[timeLabel]" options:0 metrics:nil views:views]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[gbv]|" options:0 metrics:nil views:views]];

        [greyBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.heartImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:greyBackgroundView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-5.0]];

        [greyBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.heartLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:greyBackgroundView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:8.0]];

        [greyBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.heartImg attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:greyBackgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

        [greyBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.heartLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:greyBackgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

    }

    return self;
}

- (void) setLabelNames {
    
}

@end
