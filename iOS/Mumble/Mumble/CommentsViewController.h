//
//  CommentsViewController.h
//  Mumble
//
//  Created by Stephen Sowole on 03/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mumble.h"

@interface CommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property Mumble *mumble;

@end
