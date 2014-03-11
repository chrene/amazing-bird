//
//  ABPlayer.h
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 24/02/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "ABGameCharacter.h"

@class ABPlayer;

@interface ABNormalBird : ABGameCharacter

- (instancetype)initAtPosition:(CGPoint)position withPlayer:(ABPlayer *)player;
- (BOOL)paralyzed;

@end
