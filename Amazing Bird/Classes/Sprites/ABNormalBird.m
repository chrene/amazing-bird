//
//  ABPlayer.m
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 24/02/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "ABNormalBird.h"
#import "ABPlayer.h"
#import "ABGameScene.h"

#define kAnimIdleKey @"animIdleKey"
#define kAnimMoveKey @"animMoveKey"

@interface ABNormalBird()
@property (nonatomic, weak) ABPlayer *player;
@property (nonatomic) CGFloat velocity;
@end

@implementation ABNormalBird

- (instancetype)initAtPosition:(CGPoint)position withPlayer:(ABPlayer *)player {

    self = [super initWithTexture:[SKTexture textureWithImageNamed:@"bird_anim0"]  position:position];
    if (self) {
		self.player = player;
		self.hitPoints = 1;
		self.maxHitPoints = 3;
		self.movementSpeed = 7;
	}
    return self;
}

- (void)configurePhysicsBody
{
	CGFloat offsetX = self.size.width * self.anchorPoint.x;
	CGFloat offsetY = self.size.height * self.anchorPoint.y;

	CGMutablePathRef path = CGPathCreateMutable();

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGPathMoveToPoint(path, NULL, 4 - offsetX, 19 - offsetY);
        CGPathAddLineToPoint(path, NULL, 36 - offsetX, 29 - offsetY);
        CGPathAddLineToPoint(path, NULL, 54 - offsetX, 22 - offsetY);
        CGPathAddLineToPoint(path, NULL, 37 - offsetX, 2 - offsetY);
        CGPathAddLineToPoint(path, NULL, 10 - offsetX, 4 - offsetY);
    } else {
        CGPathMoveToPoint(path, NULL, 3 - offsetX, 9 - offsetY);
        CGPathAddLineToPoint(path, NULL, 18 - offsetX, 14 - offsetY);
        CGPathAddLineToPoint(path, NULL, 25 - offsetX, 11 - offsetY);
        CGPathAddLineToPoint(path, NULL, 18 - offsetX, 1 - offsetY);
        CGPathAddLineToPoint(path, NULL, 4 - offsetX, 3 - offsetY);
        CGPathAddLineToPoint(path, NULL, 1 - offsetX, 9 - offsetY);
    }

	CGPathCloseSubpath(path);

	self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];

    CGPathRelease(path);
	self.physicsBody.dynamic = NO;
    self.physicsBody.mass = 0.01;
    [self reset];

}

- (void)idle {

	[super idle];
	self.status = ABGameCharacterStatusIdle;
	self.physicsBody.dynamic = NO;
	[self animateWithFrames:sharedBirdAnimFrames interval:1.0/32.0 withKey:kAnimIdleKey];
	if ([self actionForKey:@"idleMovementKey"]) {
		return;
	}
	[self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction moveByX:0 y:-7 duration:1],
																	   [SKAction moveByX:0 y:7 duration:1]]]] withKey:@"idleMovementKey"];
	
}

- (BOOL)paralyzed
{
	 return self.status == ABGameCharacterStatusDead
		 || self.status == ABGameCharacterStatusDying
		 || self.status == ABGameCharacterStatusReviving;
}

- (void)move
{
	if (![self paralyzed]) {
		self.status = ABGameCharacterStatusMoving;
		self.velocity = self.movementSpeed;
		self.physicsBody.dynamic = YES;
		self.physicsBody.velocity = CGVectorMake(0, 0);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.physicsBody applyImpulse:CGVectorMake(0, 7.0)];
        } else {
            [self.physicsBody applyImpulse:CGVectorMake(0, 3.5)];
        }
        [self animateWithFrames:sharedBirdAnimFrames interval:1.0/45.0 withKey:kAnimMoveKey];
	}
}

- (void)performDeath
{
	self.status = ABGameCharacterStatusDying;
	self.physicsBody.collisionBitMask = 0;
	self.physicsBody.contactTestBitMask = 0;
}

- (void)reset {
	self.physicsBody.categoryBitMask = ABColliderTypeBird;
	self.physicsBody.contactTestBitMask = ABColliderTypeLifeCloud;
	self.physicsBody.collisionBitMask = ABColliderTypeCloud;
	self.physicsBody.allowsRotation = YES;
}

- (void)revive
{
	if ((self.status != ABGameCharacterStatusReviving)) {
		self.status = ABGameCharacterStatusReviving;
		[self runAction:[SKAction moveTo:CGPointMake([self characterScene].size.width/2, self.position.y) duration:0]];
		self.zRotation = 0;
		self.physicsBody.dynamic = NO;
		SKAction *wait = [SKAction waitForDuration:.5];
		SKAction *moveUp = [SKAction moveTo:CGPointMake(self.characterScene.size.width/2,
														self.characterScene.size.height/2) duration:.7];
		SKAction *rotate = [SKAction rotateByAngle:M_PI * 2 duration:.7];
		SKAction *reviveAction = [SKAction sequence:@[wait, [SKAction group:@[moveUp, rotate]]]];
		reviveAction.timingMode = SKActionTimingEaseIn;
		[self runAction:reviveAction completion:^{
			[self idle];
			[self reset];
		}];
	}
}


- (void)update:(NSTimeInterval)delta
{
	if (self.status != ABGameCharacterStatusReviving) {
		if (self.position.y + self.size.height < 0) {
			self.status = ABGameCharacterStatusDead;
		}
	}

}

#pragma mark - Animations and frames

- (void)animateWithFrames:(NSArray *)frames interval:(NSTimeInterval)interval withKey:(NSString *)key
{
	[super animateWithFrames:frames interval:interval withKey:key];
	if (![key isEqualToString:kAnimIdleKey]) {
		//[self removeActionForKey:@"idleMovementKey"];
	}
}

- (void)completedAnimationWithKey:(NSString *)animKey
{
	if ([animKey isEqualToString:kAnimIdleKey]) {
		[self idle];
	}
}

+ (void)loadSharedFrames
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedBirdAnimFrames = [ABGraphicsUtilities loadFramesFromAtlas:@"bird_anim" baseName:@"bird_anim"];
	});
}

static NSArray *sharedBirdAnimFrames = nil;
- (NSArray *)birdAnimFrames {
	return sharedBirdAnimFrames;
}

- (void)addToScene:(ABGameScene *)scene
{
	[scene addNode:self atWorldLayer:ABWorldLayerGameCharacters];
	self.position = CGPointMake(scene.size.width/2, -100);
	[self revive];
}

- (BOOL)applyDamage:(int)damage
{
	BOOL dead = [super applyDamage:damage];
	if (dead) {
		[self performDeath];
	}
	return dead;
}


@end
