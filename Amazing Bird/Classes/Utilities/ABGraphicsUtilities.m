//
//  ABGraphicsUtilities.m
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 27/02/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "ABGraphicsUtilities.h"

@implementation ABGraphicsUtilities

+ (NSArray *)loadFramesFromAtlas:(NSString *)atlas baseName:(NSString *)baseName
{
	SKTextureAtlas *textureAtlas = [SKTextureAtlas atlasNamed:atlas];
	NSUInteger numberOfFrames = textureAtlas.textureNames.count;
	NSMutableArray *frames = [NSMutableArray arrayWithCapacity:numberOfFrames];

	for (int i = 0; i < numberOfFrames/4; ++i) {
		id textureName = [NSString stringWithFormat:@"%@%d.png", baseName, i];
		[frames addObject:[textureAtlas textureNamed:textureName]];
	}

	return frames;
}

@end