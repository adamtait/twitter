//
//  AppDelegate.m
//  twitter
//
//  Created by Adam Tait on 1/29/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "HomeTableViewController.h"
#import "Color.h"
#import "TwitterClient.h"
#import "User.h"

@interface AppDelegate ()

    - (void)userDidLogin:(id)notification;
    - (void)userDidLogout:(id)notification;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if ([TwitterClient instance].accessToken) {
        // open the HomeTableViewController
        [self userDidLogin:nil];
    } else {
        // open LoginViewController
        [self userDidLogout:nil];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:[NSDictionary dictionaryWithObject:url forKey:kAFApplicationLaunchOptionsURLKey]];
    
    // TODO: is this really necessary?
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma private methods for handling changes from OAuth1Client notifications

- (void)userDidLogin:(id)notification
{
    HomeTableViewController *homeTableViewController = [[HomeTableViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:homeTableViewController];
    self.window.rootViewController = navigationController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout:) name:@"UserDidLogoutNotification" object:nil];
}

- (void)userDidLogout:(id)notification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:UserDidLoginNotification object:nil];
    self.window.rootViewController = [[LoginViewController alloc] init];
}


@end
