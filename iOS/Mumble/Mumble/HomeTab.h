//
//  HomeTab.h
//  Mumble
//
//  Created by Stephen Sowole on 18/10/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UITabBarController+hidable.h"
#import "PostMessageViewController.h"

@interface HomeTab : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate>

@property BOOL isMainViewController;
@property BOOL showHot;
@property BOOL showNew;

- (void) postMessage;

@end
