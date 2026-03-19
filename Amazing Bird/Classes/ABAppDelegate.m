//
//  ABAppDelegate.m
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 24/02/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "ABAppDelegate.h"
#import "ABPlayer.h"

@implementation ABAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self load];
	return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options
{
	return [UISceneConfiguration configurationWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[self save];
}

- (void)save
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:[ABPlayer sharedPlayer].highscore forKey:@"highscore"];
	[defaults setBool:[ABPlayer sharedPlayer].isPremium forKey:@"premium"];
}

- (void)load
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[[ABPlayer sharedPlayer] setHighscore:(int)[defaults integerForKey:@"highscore"]];
	[[ABPlayer sharedPlayer] setPremium:[defaults boolForKey:@"premium"]];
}

@end
