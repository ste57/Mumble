//
//  PostMessageViewController.m
//  Mumble
//
//  Created by Stephen Sowole on 01/11/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import "PostMessageViewController.h"
#import "Config.h"
#import "UIPlaceHolderTextView.h"
#import <Parse/Parse.h>
#import "UIButton+Extensions.h"


@implementation PostMessageViewController {
    
    UILabel *charCounterlbl;
    
    UIPlaceHolderTextView *mumbleTextView, *locationTextView;
    
    NSString *userID;
    
    CLLocationManager *locationManager;
    
    CLLocation *userLocation;
}

@synthesize tagTitle;

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self checkUserParseID];
    
    [self createDisplay];
    
    [self initiateCoreLocation];
    
    [locationManager startUpdatingLocation];
}

- (void) initiateCoreLocation {
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    PFQuery *query = [PFQuery queryWithClassName:USER_DATA_CLASS];
    
    [query getObjectInBackgroundWithId:userID block:^(PFObject *userPFObject, NSError *error) {
        
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:newLocation.coordinate.latitude
                                                      longitude:newLocation.coordinate.longitude];
        
        [userPFObject setObject:geoPoint forKey:USER_DATA_LOCATION];
        [userPFObject saveInBackground];
    }];
    
    userLocation = newLocation;
    
    [locationManager stopUpdatingLocation];
}

- (void) checkUserParseID {
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:USERID]) {
        
        PFObject *user = [PFObject objectWithClassName:USER_DATA_CLASS];
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                userID = user.objectId;
                
                [[NSUserDefaults standardUserDefaults] setObject:userID forKey:USERID];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }];
        
    } else {
        
        userID = [[NSUserDefaults standardUserDefaults] objectForKey:USERID];
    }
}

- (void) createDisplay {
    
    [self createCloseButton];
    
    [self createPostButton];
    
    [self createCharacterCounter];
    
    [self createMumbleTextView];
}

- (void) createMumbleTextView {
    
    // main mumble textview
    
    mumbleTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(15.0, 80.0, self.view.frame.size.width - 30.0, 150.0)];
    
    mumbleTextView.clipsToBounds = YES;
    
    mumbleTextView.placeholder = POST_TEXTVIEW_PLACEHOLDER;
    
    mumbleTextView.placeholderColor = [UIColor lightGrayColor];
    
    mumbleTextView.font = [UIFont fontWithName:MUMBLE_FONT_NAME size:18.0];
    
    mumbleTextView.delegate = self;
    
    [self.view addSubview:mumbleTextView];
    
    [mumbleTextView setKeyboardType:UIKeyboardTypeTwitter];
    
    [mumbleTextView becomeFirstResponder];
    
    // Tag View
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)];
    
    toolBar.barTintColor = NAV_BAR_HEADER_COLOUR;
    
    toolBar.translucent = NO;
    
    locationTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width-30.0, 40.0)];
    
    locationTextView.clipsToBounds = YES;
    
    locationTextView.backgroundColor = NAV_BAR_HEADER_COLOUR;
    
    locationTextView.delegate = self;
    
    locationTextView.editable = NO;
    
    locationTextView.selectable = NO;
    
    locationTextView.textColor = [UIColor whiteColor];
    
    locationTextView.textAlignment = NSTextAlignmentCenter;
    
    locationTextView.font = [UIFont fontWithName:MUMBLE_FONT_NAME size:18.0];
    
    locationTextView.placeholderColor = [UIColor whiteColor];
    
    if (tagTitle) {
 
        [toolBar setItems:[NSArray arrayWithObject:[[UIBarButtonItem alloc] initWithCustomView:locationTextView]]];
        
        mumbleTextView.inputAccessoryView = toolBar;
        
        locationTextView.text = tagTitle;
    }
}

- (void) textViewDidChange:(UITextView *)textView {
    
    charCounterlbl.text = [NSString stringWithFormat:@"%i", MUMBLE_CHARACTER_LIMIT - (int)mumbleTextView.text.length - (int)tagTitle.length];
    
    if ((int)textView.text.length > MUMBLE_CHARACTER_LIMIT - (int)tagTitle.length) {
        
        charCounterlbl.textColor = [UIColor redColor];
        
    } else {
        
        charCounterlbl.textColor = [UIColor lightGrayColor];
    }
}

- (BOOL) exceededMaxNumberOfLines:(NSRange)range :(NSString *)text {
    
    NSMutableString *t = [NSMutableString stringWithString: mumbleTextView.text];
    
    [t replaceCharactersInRange:range withString:text];
    
    NSUInteger numberOfLines = 0;
    
    for (NSUInteger i = 0; i < t.length; i++) {
        
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember: [t characterAtIndex: i]]) {
            
            numberOfLines++;
        }
    }
    
    return (numberOfLines < MUMBLE_MAX_NUMBER_OF_LINES);
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (textView == mumbleTextView) {
        
        return [self exceededMaxNumberOfLines:range :text];
    }
    
    if ([text length] == 0) {
        
        if([textView.text length] != 0) {
            
            return YES;
        }
        
    } else {
        
        if (textView == mumbleTextView && [[mumbleTextView text] length] > (MUMBLE_CHARACTER_LIMIT - 1 - (int)tagTitle.length)) {
            
            return NO;
        }
    }
    
    return YES;
}

- (void) createPostButton {
    
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    postButton.frame = CGRectMake(0, 0, 50.0, 30.0);
    
    postButton.center = CGPointMake(self.view.frame.size.width - 40.0, 50.0);
    
    postButton.titleLabel.font = [UIFont fontWithName:MUMBLE_FONT_NAME size:19.0];
    
    [postButton setTitle:@"Post" forState:UIControlStateNormal];
    
    [postButton setTitleColor:NAV_BAR_HEADER_COLOUR forState:UIControlStateNormal];
    
    [postButton addTarget:self action:@selector(postMumble) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:postButton];
}

- (void) postMumble {
    
    if ((mumbleTextView.text.length < (MUMBLE_CHARACTER_LIMIT - (int)tagTitle.length)) && (mumbleTextView.text.length > 0)) {

        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        NSArray *words = [mumbleTextView.text componentsSeparatedByString:@" "];
        
        for (NSString *word in words) {
            
            if ([word hasPrefix:TAG_IDENTIFIER]) {
                
                NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                
                NSString *trimmedReplacement = [ word stringByTrimmingCharactersInSet:charactersToRemove ];
                
                [array addObject:[NSString stringWithFormat:@"@%@", trimmedReplacement]];
            }
        }
        
        if (tagTitle) {
            
            [array addObject:tagTitle];
            mumbleTextView.text = [NSString stringWithFormat:@"%@ %@", mumbleTextView.text, tagTitle];
        }
        
        PFObject *mumble = [PFObject objectWithClassName:MUMBLE_DATA_CLASS];
        
        [mumble setObject:mumbleTextView.text forKey:MUMBLE_DATA_CLASS_CONTENT];

        [mumble setObject:array forKey:MUMBLE_DATA_TAGS];
        
        [mumble setObject:IPHONE_IDENTIFIER_TAG forKey:MUMBLE_DATA_PHONE_TYPE];
        
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:userLocation.coordinate.latitude
                                                      longitude:userLocation.coordinate.longitude];
        
        [mumble setObject:geoPoint forKey:MUMBLE_DATA_LOCATION];
        
        [mumble setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USERID] forKey:MUMBLE_DATA_USER];
        
        [mumble saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            NSMutableArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:MUMBLES_BY_USER];
            
            if (![array containsObject:mumble.objectId]) {
                
                [array addObject:mumble.objectId];
                
                [[NSUserDefaults standardUserDefaults] setObject:array forKey:MUMBLES_BY_USER];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_TABLEVIEW object:nil];
            }
        }];
        
        [self closeView];
    }
}

- (void) createCharacterCounter {
    
    charCounterlbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50.0, 30.0)];
    
    charCounterlbl.textAlignment = NSTextAlignmentRight;
    
    charCounterlbl.center = CGPointMake(self.view.frame.size.width - 90.0, 50.0);
    
    charCounterlbl.text = [NSString stringWithFormat:@"%i", MUMBLE_CHARACTER_LIMIT - (int)tagTitle.length];
    
    charCounterlbl.font = [UIFont fontWithName:MUMBLE_FONT_NAME size:16.0];
    
    charCounterlbl.textColor = [UIColor lightGrayColor];
    
    [self.view addSubview:charCounterlbl];
}

- (void) createCloseButton {
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [closeButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    
    closeButton.frame = CGRectMake(0, 0, 18.0, 18.0);
    
    closeButton.center = CGPointMake(30.0, 50.0);
    
    [closeButton setBackgroundImage:[UIImage imageNamed:@"closeButton"] forState:UIControlStateNormal];
    
    [closeButton setHitTestEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];
    
    [self.view addSubview:closeButton];
}

- (void) closeView {
    
    [mumbleTextView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
