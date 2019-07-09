//
//  ABGameObstacle.h
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 03/09/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "ABGameCharacter.h"

@interface ABGameObstacle : ABGameCharacter
- (instancetype)initAtPosition:(CGPoint)position;
@property (nonatomic, assign, getter = hasPassedPlayerCharacter) BOOL passedPlayerCharacter;

- (NSString *)textureName;

@end
