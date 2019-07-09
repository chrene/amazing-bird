//
//  ABSeedBag.m
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 03/09/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "ABSeedBag.h"
#import "ABPlayer.h"
#import "BMGlyphLabel.h"
#import "ABGameCharacter.h"
#import "ABGameScene.h"
#import "ABRandom.h"

@implementation ABSeedBag {
//  SKSpriteNode *_scoreLabel;
}

- (NSString *)textureName {
    return @"Seed_bag";
}


- (instancetype)initAtPosition:(CGPoint)position {
	self = [super initAtPosition:position];
	if (self) {
		self.name = @"seed_bag";
	}
	return self;
}

- (void)configurePhysicsBody
{
  self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.height/2];
	self.physicsBody.affectedByGravity = NO;
	self.physicsBody.linearDamping = 0;
	self.physicsBody.allowsRotation = NO;
	self.physicsBody.categoryBitMask = ABColliderTypeSeedBag;
	self.physicsBody.collisionBitMask = 0;
	self.physicsBody.contactTestBitMask = ABColliderTypeBird | ABColliderTypeSeedBag;
}

- (void)reset
{
	[super reset];
  self.alpha = 1.0;
	collidedWithObstacle = NO;
	self.passedPlayerCharacter = NO;
}

- (void)move {
#if TARGET_OS_IOS
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.physicsBody.velocity = CGVectorMake(-abRand(350, 450), 0);
	}
	else {
		self.physicsBody.velocity = CGVectorMake(-abRand(200, 350), 0);
	}
#elif TARGET_OS_TV
  self.physicsBody.velocity = CGVectorMake(-abRand(200, 350), 0);
#endif
}

- (void)addToScene:(ABGameScene *)scene atPosition:(CGPoint)position {
	[super addToScene:scene atPosition:position];
	[self move];
}

- (void)update:(NSTimeInterval)delta {
	if (self.position.x + self.size.width / 2 < 0 || self.position.y + self.size.height / 2 < 0) {
		[self removeFromParent];
	}
}

static BOOL collidedWithObstacle = NO;
- (void)collideWith:(SKPhysicsBody *)other
{

  if (other.categoryBitMask == ABColliderTypeBird)
  {
    [ABPlayer sharedPlayer].score += 500;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      SKSpriteNode *_scoreLabel = [SKSpriteNode spriteNodeWithImageNamed:@"Score"];

      _scoreLabel.position = CGPointMake(self.position.x - self.size.width/2.0, self.position.y + self.size.height/2.0);
      [self.characterScene addNode:_scoreLabel atWorldLayer:ABWorldLayerForeground];
      [_scoreLabel setScale:0.0];

      id scaleIn1 = [SKAction scaleTo:1.1 duration:0.2];
      id scaleIn2 = [SKAction scaleTo:0.9 duration:0.2];
      id scaleIn3 = [SKAction scaleTo:1.0 duration:0.2];
      id pause = [SKAction waitForDuration:0.6];
      id scaleOut = [SKAction scaleTo:0.0 duration:0.2];
      id fadeOut = [SKAction fadeOutWithDuration:0.2];

      [_scoreLabel runAction:[SKAction sequence:@[scaleIn1, scaleIn2, scaleIn3, pause, [SKAction group:@[scaleOut, fadeOut]]]] completion:^{
        [_scoreLabel removeFromParent];
      }];

      [self removeFromParent];
    });


	}
	else if (other.categoryBitMask == ABColliderTypeCloud || other.categoryBitMask == ABColliderTypeSeedBag) {
		if (!collidedWithObstacle) {
			[self runAction:[SKAction fadeAlphaTo:abRand(.3, .9) duration:1]];
			collidedWithObstacle = YES;
		}
	}
}

- (void)performDeath {
	self.status = ABGameCharacterStatusDying;
	[self runAction:[SKAction fadeAlphaTo:0 duration:.2] completion: ^{
	    [self removeFromParent];
	    self.status = ABGameCharacterStatusDead;
	}];
}

+ (void)loadSharedFrames {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    sharedCloudTexture = [[SKTextureAtlas atlasNamed:@"sprites"] textureNamed:@"Cloud"];
	});
}

static SKTexture *sharedCloudTexture = nil;
- (SKTexture *)cloudTexture {
	return sharedCloudTexture;
}


@end
