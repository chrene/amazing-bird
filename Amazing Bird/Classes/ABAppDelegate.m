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
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask,
														 YES);
	NSString *documentPath = [paths firstObject];
	NSString *filePath = [documentPath stringByAppendingPathComponent:@"player.dat"];

	NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
	[encoder encodeBool:[ABPlayer sharedPlayer].isPremium forKey:@"premium"];
	[encoder encodeInt:[ABPlayer sharedPlayer].highscore forKey:@"highscore"];
	[encoder finishEncoding];
	[encoder.encodedData writeToFile:filePath atomically:YES];
}

- (void)load
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask,
														 YES);
	NSString *documentPath = [paths firstObject];
	NSString *filePath = [documentPath stringByAppendingPathComponent:@"player.dat"];
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	if (data) {
		NSError *error = nil;
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
		if (!error) {
			decoder.requiresSecureCoding = NO;
			[[ABPlayer sharedPlayer] setHighscore:[decoder decodeIntForKey:@"highscore"]];
			[[ABPlayer sharedPlayer] setPremium:[decoder decodeBoolForKey:@"premium"]];
			[decoder finishDecoding];
		}
	}
}

@end
