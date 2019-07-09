//
//  ABGameObstacle.m
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 03/09/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "ABGameObstacle.h"

@implementation ABGameObstacle

- (NSString *)textureName
{
    return nil;
}

- (instancetype)initAtPosition:(CGPoint)position {


	self = [super initWithTexture:[SKTexture textureWithImageNamed:[self textureName]]
	                     position:position];
	return self;
}



@end
