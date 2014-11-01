//
//  UIPlaceHolderTextView.h
//  Mumble
//
//  Created by Stephen Sowole on 01/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end