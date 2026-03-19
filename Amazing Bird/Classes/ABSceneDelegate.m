//
//  ABSceneDelegate.m
//  Amazing Bird
//
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "ABSceneDelegate.h"
#import "ABAppDelegate.h"

@implementation ABSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions
{
    if (![scene isKindOfClass:[UIWindowScene class]]) return;
    UIWindowScene *windowScene = (UIWindowScene *)scene;

    NSString *storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"Main_iPad" : @"Main_iPhone";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *rootVC = [storyboard instantiateInitialViewController];

    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
}

- (void)sceneWillEnterForeground:(UIScene *)scene
{
    [(ABAppDelegate *)[UIApplication sharedApplication].delegate load];
}

- (void)sceneDidEnterBackground:(UIScene *)scene
{
    [(ABAppDelegate *)[UIApplication sharedApplication].delegate save];
}

@end
