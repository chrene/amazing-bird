//
//  ABCloud.h
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 25/02/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "ABGameCharacter.h"

@interface ABCloud : ABGameCharacter

- (instancetype)initAtPosition:(CGPoint)position;
@property (nonatomic, assign, getter = hasPassedPlayerCharacter) BOOL passedPlayerCharacter;

@end
