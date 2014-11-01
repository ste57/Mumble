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


@implementation PostMessageViewController {

    UILabel *charCounterlbl;
    
    UIPlaceHolderTextView *mumbleTextView;
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
    
    mumbleTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(15.0, 80.0, self.view.frame.size.width - 30.0, 150.0)];

    mumbleTextView.clipsToBounds = YES;
    
    mumbleTextView.placeholder = POST_TEXTVIEW_PLACEHOLDER;
    
    mumbleTextView.placeholderColor = [UIColor lightGrayColor];
    
    mumbleTextView.font = MUMBLE_CONTENT_TEXT_FONT;
    
    mumbleTextView.font = [UIFont fontWithName:MUMBLE_FONT_NAME size:18.0];
    
    mumbleTextView.delegate = self;
    
    [self.view addSubview:mumbleTextView];
    
    [mumbleTextView becomeFirstResponder];
}

- (void) textViewDidChange:(UITextView *)textView {
 
    charCounterlbl.text = [NSString stringWithFormat:@"%i", MUMBLE_CHARACTER_LIMIT - (int)textView.text.length];
    
    if ((int)textView.text.length > MUMBLE_CHARACTER_LIMIT) {
        
        charCounterlbl.textColor = [UIColor redColor];
        
    } else {
        
        charCounterlbl.textColor = [UIColor lightGrayColor];
    }
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text length] == 0) {
        
        if([textView.text length] != 0) {
            
            return YES;
        }
        
    } else if ([[textView text] length] > (MUMBLE_CHARACTER_LIMIT - 1)) {
        
        return NO;
    }
    
    return YES;
}

- (void) createPostButton {
    
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    postButton.frame = CGRectMake(0, 0, 50.0, 30.0);
    
    postButton.center = CGPointMake(280.0, 50.0);
    
    postButton.titleLabel.font = [UIFont fontWithName:MUMBLE_FONT_NAME size:19.0];
    
    [postButton setTitle:@"Post" forState:UIControlStateNormal];
    
    [postButton setTitleColor:NAV_BAR_HEADER_COLOUR forState:UIControlStateNormal];
    
    [self.view addSubview:postButton];
}

- (void) createCharacterCounter {
    
    charCounterlbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50.0, 30.0)];
    
    charCounterlbl.textAlignment = NSTextAlignmentRight;
    
    charCounterlbl.center = CGPointMake(230.0, 50.0);
    
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
    
    [mumbleTextView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
