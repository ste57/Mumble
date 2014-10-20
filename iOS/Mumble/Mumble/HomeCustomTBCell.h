//
//  HomeCustomTBCell.h
//  Mumble
//
//  Created by Stephen Sowole on 18/10/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mumble.h"

@interface HomeCustomTBCell : UITableViewCell

@property (strong, nonatomic) Mumble *mumble;

- (void) createLabels;

@end
