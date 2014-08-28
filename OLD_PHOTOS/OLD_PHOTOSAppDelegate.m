//
//  OLD_PHOTOSAppDelegate.m
//  OLD_PHOTOS
//
//  Created by 井島 一貴 on 13/04/10.
//  Copyright (c) 2013年 209crc. All rights reserved.
//

#import "OLD_PHOTOSAppDelegate.h"

#import "OLD_PHOTOSViewController.h"

@implementation OLD_PHOTOSAppDelegate

@synthesize displayHeight, displayWidth, statusbarHeight;
@synthesize fontSize, fontColor, numWidth;
@synthesize scaleTrans, leftRotateTrans, rightRotateTrans, reverseTrans, idleTrans, upTrans;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

	[UIApplication sharedApplication].statusBarHidden = YES;
	
	displayWidth = [[UIScreen mainScreen] applicationFrame].size.width;
	displayHeight = [[UIScreen mainScreen] applicationFrame].size.height;
	if ([[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0) {
		statusbarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
	}
	else {
		statusbarHeight = 0;
	}
	
	scaleTrans = CGAffineTransformMakeScale(1, displayHeight / displayHeight);
	leftRotateTrans = CGAffineTransformMakeRotation(M_PI/2);
	rightRotateTrans = CGAffineTransformMakeRotation(-1 * M_PI/2);
	idleTrans = CGAffineTransformIdentity;
	reverseTrans = CGAffineTransformMakeRotation(M_PI);	
	upTrans = CGAffineTransformMakeTranslation(0, -1 * displayHeight);
	
	fontColor = [UIColor blackColor];

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		fontSize = 18;
		numWidth = 44;
	    self.viewController = [[OLD_PHOTOSViewController alloc] initWithNibName:@"OLD_PHOTOSViewController_iPhone" bundle:nil];
	} else {
		fontSize = 24;
		numWidth = 88;
	    self.viewController = [[OLD_PHOTOSViewController alloc] initWithNibName:@"OLD_PHOTOSViewController_iPad" bundle:nil];
	}
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
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

@end
