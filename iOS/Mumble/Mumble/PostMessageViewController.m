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


@implementation PostMessageViewController {
    
    UILabel *charCounterlbl;
    
    UIPlaceHolderTextView *mumbleTextView, *locationTextView;
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createDisplay];
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
    
    mumbleTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [self.view addSubview:mumbleTextView];
    
    [mumbleTextView becomeFirstResponder];
    
    
    // where are you? textview
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)];
    
    toolBar.barTintColor = [UIColor whiteColor];
    
    locationTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width-30.0, 44.0)];
    
    locationTextView.clipsToBounds = YES;
    
    locationTextView.delegate = self;
    
    locationTextView.textColor = [UIColor blackColor];
    
    locationTextView.placeholderColor = [UIColor lightGrayColor];
    
    locationTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    
    locationTextView.placeholder = LOCATION_TEXTVIEW_PLACEHOLDER;
    
    [toolBar setItems:[NSArray arrayWithObject:[[UIBarButtonItem alloc] initWithCustomView:locationTextView]]];
    
    mumbleTextView.inputAccessoryView = toolBar;
}

- (void) addLocationIdentifier:(UITextView*)textView {
    
    if (textView != mumbleTextView) {
        
        if (locationTextView.text.length < 1) {
            
            locationTextView.text = LOCATION_IDENTIFIER;
            
        }
        
        NSString *text = locationTextView.text;
        
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:text];
        
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, LOCATION_IDENTIFIER.length)];
        
        [locationTextView setAttributedText:string];
        
        locationTextView.font = mumbleTextView.font;
    }
}

- (void) removeLocationIdentifier {
    
    if (locationTextView.text.length < 2) {
        
        locationTextView.text = @"";
    }
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    
    [self removeLocationIdentifier];
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    
    [self addLocationIdentifier:textView];
}

- (void) textViewDidChange:(UITextView *)textView {
    
    [self addLocationIdentifier:textView];
    
    charCounterlbl.text = [NSString stringWithFormat:@"%i", MUMBLE_CHARACTER_LIMIT - (int)mumbleTextView.text.length];
    
    if ((int)textView.text.length > MUMBLE_CHARACTER_LIMIT) {
        
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
        
        if (textView == mumbleTextView && [[mumbleTextView text] length] > (MUMBLE_CHARACTER_LIMIT - 1)) {
            
            return NO;
        }
        
        if (textView == locationTextView) {
            
            if ([[locationTextView text] length] > (LOCATION_CHARACTER_LIMIT)) {
                
                return NO;
                
            } else if (textView == locationTextView) {
                
                NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
                BOOL valid = [[text stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
                return valid;
            }
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
    
    if ((mumbleTextView.text.length < MUMBLE_CHARACTER_LIMIT) && (mumbleTextView.text.length > 0) && (locationTextView.text.length > 1 || locationTextView.text.length == 0)) {
        
        PFObject *mumble = [PFObject objectWithClassName:MUMBLE_DATA_CLASS];
        
        [mumble setObject:mumbleTextView.text forKey:MUMBLE_DATA_CLASS_CONTENT];
        
        [mumble setObject:locationTextView.text forKey:MUMBLE_DATA_MSG_LOCATION];
        
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
    
    charCounterlbl.text = [NSString stringWithFormat:@"%i", MUMBLE_CHARACTER_LIMIT];
    
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
    
    [self.view addSubview:closeButton];
}

- (void) closeView {
    
    [locationTextView resignFirstResponder];
    [mumbleTextView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
