//
//  CommentsViewController.h
//  Mumble
//
//  Created by Stephen Sowole on 03/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mumble.h"
#import "SLKTextViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface CommentsViewController : SLKTextViewController <UITableViewDataSource, UITableViewDelegate>

@property Mumble *mumble;

- (void) shareButtonClicked;

- (void) pushCommentsCount;

@end
