//
//  Mumble.h
//  Mumble
//
//  Created by Stephen Sowole on 18/10/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Mumble : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *createdAt;
@property (strong, nonatomic) NSArray *tags;
@property long comments;
@property long likes;

@property (nonatomic) double cellHeight;

@end
