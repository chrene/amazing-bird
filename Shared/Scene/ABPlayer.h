//
//  ABPlayer.h
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 26/02/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.

#import <Foundation/Foundation.h>

@interface ABPlayer : NSObject

+ (instancetype)sharedPlayer;

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int highscore;
@property (nonatomic, getter = isPremium) BOOL premium;
@property (nonatomic, assign, readonly) BOOL highscoreChanged;

@end
