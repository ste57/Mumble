//
//  CommentsTableViewCell.h
//  Mumble
//
//  Created by Stephen Sowole on 03/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface CommentsTableViewCell : UITableViewCell

@property (nonatomic,strong) Comment *comment;

- (void) setLabels;

- (void) createLabels;

@end
