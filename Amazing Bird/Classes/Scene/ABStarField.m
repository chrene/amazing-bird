//
//  ABStarField.m
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 08/03/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "ABStarField.h"
#import "ABRandom.h"

@implementation ABStarField {
	SKSpriteNode *starField1;
	SKSpriteNode *starField2;
}

- (instancetype)initWithSize:(CGSize)size
{
    self = [super init];
	self.size = size;
    if (self) {
		starField1 = [self starField];
		starField2 = [self starField];
		starField1.position = CGPointMake(0, 0);
		starField2.position = CGPointMake(size.width + 1, 0);
		[self addChild:starField1];
		[self addChild:starField2];
    }
    return self;
}

- (SKSpriteNode *)starField {
	SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];

	SKSpriteNode *starField = [SKSpriteNode node];
	starField.size = self.size;
	starField.anchorPoint = CGPointZero;
	for (int i = 0; i < 50; ++i) {
		SKSpriteNode *star = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:[NSString stringWithFormat:@"Star%d", (int)abRand(1, (abRandf() > .5) ? 4 : 3)]]];
		[starField addChild:star];
		CGFloat posY = abRand(0, self.size.height);
		star.position = CGPointMake( abRandf() * self.size.width,
									posY );
		star.alpha = (CGFloat)(posY/self.size.height);
	}
	return starField;
}

static NSTimeInterval interval;
- (void)update:(NSTimeInterval)delta {
	interval += delta;
    CGFloat dx = [UIScreen mainScreen].scale * .5;
	if (interval > .03) {
		interval = 0;
		starField1.position = CGPointMake(starField1.position.x - dx, starField1.position.y);
		starField2.position = CGPointMake(starField2.position.x - dx, starField2.position.y);
	}
	if (starField1.position.x < -starField1.size.width) {
		starField1.position = CGPointMake(starField1.size.width, 0);
	}

	else if (starField2.position.x < -starField2.size.width) {
		starField2.position = CGPointMake(starField2.size.width, 0);
	}
}

@end
