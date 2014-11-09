//
//  AppDelegate.m
//  Mumble
//
//  Created by Stephen Sowole on 18/10/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "HomeTab.h"
#import "TrendingTabViewController.h"
#import "MeTabViewController.h"
#import "Config.h"
#import "XHTwitterPaggingViewer.h"
#import "HotTagsViewController.h"

@implementation AppDelegate {
    
    HomeTab *home;
    TrendingTabViewController *trendingVC;
    MeTabViewController *meVC;
    HotTagsViewController *hotTagsVC;
    
    UITabBarController *tabBar;
    NSMutableArray *tabArray;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    [Parse setApplicationId:@"MRakBf8O2WvDEhrv8IHovUEVfbuZeT76XHmOUTQ2"
                  clientKey:@"ii47uvS0KLLkqmBgzzXkGZPw2FBAZejQj92ENKZH"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    tabBar = [[UITabBarController alloc] init];
    tabArray = [[NSMutableArray alloc] init];
    
    // Add Tabs
    
    [self addHomeTab];
    
    [self addTrendingTab];
    
    [self addMeTab];
    
    // Add Tab To Main Window
    
    tabBar.viewControllers = tabArray;
    
    // [[UITabBar appearance] setBarTintColor:NAV_BAR_COLOUR];
    
    [[UITabBar appearance] setTintColor:NAV_BAR_COLOUR];
    
    // Set Start View
    
    [self.window setRootViewController:tabBar];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void) addTrendingTab {
    
    /*trendingVC = [[TrendingTabViewController alloc] init];
    trendingVC.title = TRENDING_TITLE;
    [self addNavigationBar:trendingVC];*/
    
    XHTwitterPaggingViewer *twitterPaggingViewer = [[XHTwitterPaggingViewer alloc] init];
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    
    trendingVC = [[TrendingTabViewController alloc] init];
    trendingVC.title = TRENDING_HOT_TITLE;
    //trendingVC.isMainViewController = YES;
    //trendingVC.showNew = YES;
    [viewControllers addObject:trendingVC];
    
    hotTagsVC = [[HotTagsViewController alloc] init];
    hotTagsVC.title = TRENDING_TAGS_TITLE;
    //trendingVC.showHot = YES;
    [viewControllers addObject:hotTagsVC];
    
    twitterPaggingViewer.viewControllers = viewControllers;
    
    twitterPaggingViewer.title = TRENDING_TITLE;
    
    [self addNavigationBar:twitterPaggingViewer];
}

- (void) addMeTab {
    
    meVC = [[MeTabViewController alloc] init];
    meVC.title = ME_TITLE;
    [self addNavigationBar:meVC];
}

- (void) addHomeTab {
    
    XHTwitterPaggingViewer *twitterPaggingViewer = [[XHTwitterPaggingViewer alloc] init];
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    
    home = [[HomeTab alloc] init];
    home.title = HOME_NEW_TITLE;
    home.isMainViewController = YES;
    home.showNew = YES;
    [viewControllers addObject:home];
    
    home = [[HomeTab alloc] init];
    home.title = HOME_HOT_TITLE;
    home.showHot = YES;
    [viewControllers addObject:home];
    
    twitterPaggingViewer.viewControllers = viewControllers;
    
    twitterPaggingViewer.title = HOME_TITLE;
    
    twitterPaggingViewer.addPostButton = YES;
    
    twitterPaggingViewer.addSearchButton = YES;
    
    [self addNavigationBar:twitterPaggingViewer];
}

- (void) addNavigationBar:(UIViewController*)view {
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:view];
    
    navController.navigationBar.barTintColor = NAV_BAR_COLOUR;
    navController.navigationBar.tintColor = [UIColor whiteColor];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    [tabArray addObject:navController];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
