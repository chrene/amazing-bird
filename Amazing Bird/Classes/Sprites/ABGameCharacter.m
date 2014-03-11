//
//  ABGameCharacter.m
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 25/02/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "ABGameCharacter.h"
#import "ABGameScene.h"

@implementation ABGameCharacter {
	
}

- (instancetype)initWithTexture:(SKTexture *)texture position:(CGPoint)position
{
	self = [super initWithTexture:texture];
	if (self)
	{
		self.position = position;
		[self configurePhysicsBody];
	}
	return self;
}

- (void)configurePhysicsBody { /* up to subclass */}
- (void)collideWith:(SKPhysicsBody *)other { /* subclass */}

- (void)reset {
	[self removeAllActions];
	self.alpha = 1;
}

- (BOOL)applyDamage:(int)damage
{
	self.hitPoints -= damage;
	if (self.hitPoints < 0) {
		self.hitPoints = 0;
	}
	return self.hitPoints == 0;
}

// Acting
- (void)idle {

}

- (void)move {
}

- (void)performDeath {

}

- (void)revive {

}

- (void)update:(NSTimeInterval)delta {}

+ (void)loadSharedFrames { /* overriden by subclass */ }


- (void)animateWithFrames:(NSArray *)frames interval:(NSTimeInterval)interval withKey:(NSString *)key
{
	[self removeActionForKey:self.activeAnimationKey];
	[self runAction:[SKAction sequence:@[[SKAction animateWithTextures:frames timePerFrame:interval],
										 [SKAction runBlock:^{
		[self completedAnimationWithKey:key];
	}]]] withKey:key];
	self.activeAnimationKey = key;
}

- (void)completedAnimationWithKey:(NSString *)animKey { /* Overriden by subclass */ }

// Scene
- (void)addToScene:(ABGameScene *)scene atPosition:(CGPoint)position {
	[scene addNode:self atWorldLayer:ABWorldLayerGameCharacters];
	self.position = position;
}
- (ABGameScene *)characterScene {
	if ([self.scene isKindOfClass:[ABGameScene class]]) {
		return (ABGameScene *)self.scene;
	}
	return nil;
}


@end
