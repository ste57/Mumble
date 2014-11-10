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

#define POPULAR_TAG_LIMIT 1000

#define TRENDING_TAG_LIMIT 10000

#define MUMBLE_MAX_NUMBER_OF_LINES 5

#define MAX_MUMBLES_ONSCREEN 150

#define POST_TEXTVIEW_PLACEHOLDER @"What's mumbling?"

#define SEARCH_BAR_PLACEHOLDER @"Search tag"

#define TAG_IDENTIFIER @"@"

#define IPHONE_IDENTIFIER_TAG @"@iPhone"

// Tab Titles

#define TRENDING_TITLE @"Trending"
#define TRENDING_HOT_TITLE @"What's Hot"
#define TRENDING_TAGS_TITLE @"Hot Tags"

#define ME_TITLE @"Me"
#define ME_TAB_TITLE @"Me"

#define HOME_TITLE @"Near Me"
#define HOME_NEW_TITLE @"New"
#define HOME_HOT_TITLE @"Hot"

// Notifications

#define HOME_INDEX 0
#define TRENDING_INDEX 1
#define ME_INDEX 2

#define REFRESH_TABLEVIEW @"RefreshTableView"

#define COMMENTS_PRESSED @"CommentsPressed"

#define TAG_PRESSED @"TagPressed"

#define USER_PREFIX @"user_"

#define MUMBLE_1_LIKE @"Your mumble has been liked!"

#define MUMBLE_5_LIKE @"Your mumble is on 5 likes!"

#define MUMBLE_10_LIKE @"Your mumble is on 10 likes!"

#define MUMBLE_COMMENT_PUSH @"Someone replied to your mumble"

// NSUserDefaults

#define MUMBLES_BY_USER @"MumblesByUser"

#define MUMBLES_LIKED_BY_USER @"MumblesLikedByUser"

#define COMMENTS_LIKED_BY_USER @"CommentsLikedByUser"

#define USERID @"UserID"

#define LIKES @"LikesCount"

#define FLAG_ARRAY @"flaggedIDs"

// Parse Info

#define USER_DATA_CLASS @"User"
#define USER_DATA_LOCATION @"lastLocation"

#define MUMBLE_DATA_OBJECTID @"objectId"
#define MUMBLE_DATA_CLASS @"Mumble"
#define MUMBLE_DATA_CLASS_CONTENT @"content"
#define MUMBLE_DATA_TAGS @"tags"
#define MUMBLE_DATA_USER @"userID"
#define MUMBLE_DATA_LIKES @"likesCount"
#define MUMBLE_DATA_COMMENTS @"commentsCount"
#define MUMBLE_DATA_LOCATION @"userLocation"
#define MUMBLE_DATA_PHONE_TYPE @"msgLocation"
#define MUMBLE_DATA_FLAG @"flagCount"
#define MUMBLE_FLAG_FOR_DELETE 4

#define LIKES_DATA_CLASS @"Likes"
#define LIKES_MUMBLE_ID @"mumbleID"

#define COMMENTS_DATA_CLASS @"Comments"
#define COMMENTS_DATA_CONTENT @"content"
#define COMMENTS_DATA_LIKES @"likesCount"
#define COMMENTS_MUMBLE_ID @"mumbleID"
#define COMMENTS_USER @"userID"

