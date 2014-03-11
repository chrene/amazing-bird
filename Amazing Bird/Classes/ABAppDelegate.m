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

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[self save];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[self load];
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

	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];

	[encoder encodeBool:[ABPlayer sharedPlayer].isPremium forKey:@"premium"];
	[encoder encodeInt:[ABPlayer sharedPlayer].highscore forKey:@"highscore"];

	[encoder finishEncoding];
	[data writeToFile:filePath atomically:YES];

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
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		[[ABPlayer sharedPlayer] setHighscore:[decoder decodeIntForKey:@"highscore"]];
		[[ABPlayer sharedPlayer] setPremium:[decoder decodeBoolForKey:@"premium"]];

		[decoder finishDecoding];

	}
}

@end
