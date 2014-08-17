//
//  ABGameCharacter.h
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 25/02/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ABGraphicsUtilities.h"

@class ABGameScene;

typedef enum : uint8_t {
	ABColliderTypeBird = 1,
	ABColliderTypeCloud = 2,
	ABColliderTypeLifeCloud = 4
} ABColliderType;

typedef enum : uint8_t {
	ABGameCharacterStatusIdle = 1 << 1,
	    ABGameCharacterStatusDying = 1 << 2,
	    ABGameCharacterStatusDead = 1 << 3,
	    ABGameCharacterStatusReviving = 1 << 4,
	    ABGameCharacterStatusMoving = 1 << 5,
	    ABGameCharacterStatusParalyzed = ABGameCharacterStatusDying
	    & ABGameCharacterStatusDead
	    & ABGameCharacterStatusReviving
} ABGameCharacterStatus;

@interface ABGameCharacter : SKSpriteNode

#pragma mark - Properties

@property (nonatomic) int hitPoints;
@property (nonatomic) int maxHitPoints;
@property (nonatomic) NSString *activeAnimationKey;
@property (nonatomic) CGFloat movementSpeed;
@property (nonatomic) ABGameCharacterStatus status;

#pragma mark - Creation

/**
 * Initializes a standard GameCharacter sprite
 * @param texture the default texture for the sprite
 * @param position the position in the parent node
 */
- (instancetype)initWithTexture:(SKTexture *)texture position:(CGPoint)position;

- (void)update:(NSTimeInterval)delta;

#pragma mark - Overriden methods

- (void)configurePhysicsBody;
- (void)collideWith:(SKPhysicsBody *)other;
- (void)reset;
- (BOOL)applyDamage:(int)damage;

// Acting
- (void)idle;
- (void)move;
- (void)performDeath;
- (void)revive;

// Scene
- (void)addToScene:(ABGameScene *)scene atPosition:(CGPoint)position;
- (ABGameScene *)characterScene;
- (void)animateWithFrames:(NSArray *)frames interval:(NSTimeInterval)interval withKey:(NSString *)key;
- (void)completedAnimationWithKey:(NSString *)key;

+ (void)loadSharedFrames;

@end
