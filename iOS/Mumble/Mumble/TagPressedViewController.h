//
//  TagPressedViewController.h
//  Mumble
//
//  Created by Stephen Sowole on 04/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UITabBarController+hidable.h"

@interface TagPressedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate>

@end
