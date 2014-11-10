//
//  SearchViewController.h
//  Mumble
//
//  Created by Stephen Sowole on 09/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic,strong) PFGeoPoint *userGeoPoint;

@end
