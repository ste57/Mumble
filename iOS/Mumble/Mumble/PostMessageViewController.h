//
//  PostMessageViewController.h
//  Mumble
//
//  Created by Stephen Sowole on 01/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PostMessageViewController : UIViewController <UITextViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) NSString *tagTitle;

@end
