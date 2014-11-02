//
//  Config.h
//  Mumble
//
//  Created by Stephen Sowole on 18/10/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#define CELL_PADDING 15.0

#define HOME_TBCELL_DEFAULT_HEIGHT 60.0

#define MUMBLE_FONT_NAME @"Avenir"

#define MUMBLE_CONTENT_TEXT_FONT [UIFont fontWithName:MUMBLE_FONT_NAME size:16.0]

#define HOME_TIME_FONT [UIFont fontWithName:@"Avenir-Light" size:12.0]

#define NAV_BAR_COLOUR [UIColor colorWithRed:87.0/255.0 green:162.0/255.0 blue:187.0/255.0 alpha:1.0]

#define NAV_BAR_HEADER_COLOUR [UIColor colorWithRed:112.0/255.0 green:175.0/255.0 blue:196.0/255.0 alpha:1.0]

#define MUMBLE_HOME_OPTIONS_ICON_COLOUR [UIColor grayColor]

#define MUMBLE_CHARACTER_LIMIT 150

#define LOCATION_CHARACTER_LIMIT 25

#define MUMBLE_MAX_NUMBER_OF_LINES 5

#define POST_TEXTVIEW_PLACEHOLDER @"What's mumbling?"

#define LOCATION_TEXTVIEW_PLACEHOLDER @"Where are you? (optional)"

#define LOCATION_IDENTIFIER @"@"

// Notifications

#define REFRESH_TABLEVIEW @"RefreshTableView"

// NSUserDefaults

#define MUMBLES_BY_USER @"MumblesByUser"

#define USERID @"UserID"

// Parse Info

#define USER_DATA_CLASS @"User"

#define MUMBLE_DATA_CLASS @"Mumble"
#define MUMBLE_DATA_CLASS_CONTENT @"content"
#define MUMBLE_DATA_MSG_LOCATION @"msgLocation"
#define MUMBLE_DATA_USER @"userID"
#define MUMBLE_DATA_LIKES @"likesCount"
#define MUMBLE_DATA_COMMENTS @"commentsCount"

#define LIKES_DATA_CLASS @"Likes"
#define LIKES_MUMBLE_ID @"mumbleID"

#define COMMENTS_DATA_CLASS @"Comments"
#define COMMENTS_MUMBLE_ID @"mumbleID"