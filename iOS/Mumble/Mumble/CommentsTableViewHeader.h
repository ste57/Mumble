//
//  CommentTableViewHeader.h
//  Mumble
//
//  Created by Tosin Afolabi on 05/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsTableViewHeader : UIView

@property (nonatomic) UILabel *locationLabel;
@property (nonatomic) UILabel *timeLabel;
@property (nonatomic) UITextView *postLabel;
@property (nonatomic) UIButton *heartImg;
@property (nonatomic) UILabel *heartLabel;

@end
