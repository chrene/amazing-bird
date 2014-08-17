//
//  ABCloud.m
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 25/02/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "ABCloud.h"
#import "ABGameScene.h"
#import "ABNormalBird.h"

@implementation ABCloud

- (instancetype)initAtPosition:(CGPoint)position {
	self = [super initWithTexture:[SKTexture textureWithImageNamed:@"Cloud"]
	                     position:position];
	if (self) {
		self.name = @"cloud";
	}
	return self;
}

- (void)configurePhysicsBody {
	CGFloat offsetX = self.size.width * self.anchorPoint.x;
	CGFloat offsetY = self.size.height * self.anchorPoint.y;

	CGMutablePathRef path = CGPathCreateMutable();

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		CGPathMoveToPoint(path, NULL, 17 - offsetX, 85 - offsetY);
		CGPathAddLineToPoint(path, NULL, 128 - offsetX, 91 - offsetY);
		CGPathAddLineToPoint(path, NULL, 147 - offsetX, 29 - offsetY);
		CGPathAddLineToPoint(path, NULL, 101 - offsetX, 2 - offsetY);
		CGPathAddLineToPoint(path, NULL, 6 - offsetX, 21 - offsetY);
	}
	else {
		CGPathMoveToPoint(path, NULL, 4 - offsetX, 45 - offsetY);
		CGPathAddLineToPoint(path, NULL, 70 - offsetX, 53 - offsetY);
		CGPathAddLineToPoint(path, NULL, 83 - offsetX, 14 - offsetY);
		CGPathAddLineToPoint(path, NULL, 46 - offsetX, 1 - offsetY);
		CGPathAddLineToPoint(path, NULL, 2 - offsetX, 14 - offsetY);
	}

	CGPathCloseSubpath(path);
	self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
	CGPathRelease(path);

	self.physicsBody.affectedByGravity = NO;
	self.physicsBody.linearDamping = 0;
	self.physicsBody.allowsRotation = NO;
	self.physicsBody.mass = 1e1;

	self.physicsBody.categoryBitMask = ABColliderTypeCloud;
	self.physicsBody.collisionBitMask = ABColliderTypeBird;
	self.physicsBody.contactTestBitMask = ABColliderTypeBird | ABColliderTypeCloud;
}

- (void)reset {
	[super reset];
    self.alpha = 1.0;
	collidedWithCloud = NO;
	_passedPlayerCharacter = NO;
}

- (void)move {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.physicsBody.velocity = CGVectorMake(-abRand(450, 600), 0);
	}
	else {
		self.physicsBody.velocity = CGVectorMake(-abRand(200, 300), 0);
	}
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

static BOOL collidedWithCloud = NO;
- (void)collideWith:(SKPhysicsBody *)other {
	if (other.categoryBitMask == ABColliderTypeBird) {
		ABNormalBird *bird = (ABNormalBird *)other.node;
		[bird applyDamage:1];
	}
	else if (other.categoryBitMask == ABColliderTypeCloud) {
		if (!collidedWithCloud) {
			[self runAction:[SKAction fadeAlphaTo:abRand(.3, .9) duration:1]];
			collidedWithCloud = YES;
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
