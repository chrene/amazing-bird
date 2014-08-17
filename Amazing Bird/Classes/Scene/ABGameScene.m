//
//  ABMyScene.m
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 24/02/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "ABGameScene.h"
#import "ABPlayer.h"
#import "ABNormalBird.h"
#import "ABCloud.h"
#import "BMGlyphLabel.h"
#import "SKTEffects.h"
#import "ABStarField.h"

#define kSpawnCoolDown UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? .15 : .25
#define kBirdInitialPosition CGPointMake(self.size.width / 2, -20)
#define kCenterScreen CGPointMake(self.size.width / 2, self.size.height / 2)

@implementation ABGameScene {
	NSTimeInterval _lastTime;
	NSTimeInterval _spawnCoolDown;
	ABNormalBird *_playerCharacter;
	ABPlayer *_player;
	BMGlyphLabel *_scoreLabel;
	BMGlyphLabel *_highscoreLabel;
	NSMutableArray *_worldLayers;
	NSMutableArray *_gameCharacters;
	BOOL _endingGame;
	BMGlyphLabel *_tapToStartLabel;
}

- (id)initWithSize:(CGSize)size {
	if (self = [super initWithSize:size]) {
		_spawnCoolDown = kSpawnCoolDown;

		[ABNormalBird loadSharedFrames];

		// init physics world
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.physicsWorld.gravity = CGVectorMake(0, -11);
		}
		else {
			self.physicsWorld.gravity = CGVectorMake(0, -5.5);
		}
		self.physicsWorld.contactDelegate = self;

		// init player
		_player = [ABPlayer sharedPlayer];

		// init world layers
		_worldLayers = [NSMutableArray arrayWithCapacity:ABWorldLayerCount];
		for (int i = 0; i < ABWorldLayerCount; ++i) {
			SKNode *worldLayer = [SKNode node];
			worldLayer.zPosition = i;
			[self addChild:worldLayer];
			[_worldLayers addObject:worldLayer];
		}

		// init background

		SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
		SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"Background"]];
		background.position = kCenterScreen;
		[self addNode:background atWorldLayer:ABWorldLayerBackground];

		// init score label
		_scoreLabel = [BMGlyphLabel labelWithText:@"0" font:[BMGlyphFont fontWithName:@"ScoreFont"]];
		_scoreLabel.position = CGPointMake(size.width / 2, size.height * 1.1);
		[self addNode:_scoreLabel atWorldLayer:ABWorldLayerForeground];

		_highscoreLabel = [BMGlyphLabel labelWithText:[NSString stringWithFormat:@"Highscore: %d", _player.highscore] font:[BMGlyphFont fontWithName:@"ScoreFont"]];
		_highscoreLabel.position = CGPointMake(size.width / 2, size.height * .25);
		[self addNode:_highscoreLabel atWorldLayer:ABWorldLayerForeground];

		// init players character
		_playerCharacter = [[ABNormalBird alloc] initAtPosition:kCenterScreen
		                                             withPlayer:_player];
		[_playerCharacter addToScene:self atPosition:kCenterScreen];
		[_playerCharacter idle];
		[_playerCharacter.physicsBody setUsesPreciseCollisionDetection:YES];
		// Init other game characters

		int maxClouds = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 25 : 20;
		NSMutableArray *gameCharacters = [NSMutableArray arrayWithCapacity:maxClouds];
		for (int i = 0; i < maxClouds; i++) {
			[gameCharacters addObject:[[ABCloud alloc] initAtPosition:CGPointZero]];
		}


		_gameCharacters = [NSMutableArray arrayWithArray:gameCharacters];

		ABStarField *starField = [[ABStarField alloc] initWithSize:self.size];
		starField.name = @"starField";
		[self addNode:starField atWorldLayer:ABWorldLayerStars];

		_tapToStartLabel = [BMGlyphLabel labelWithText:@"Tap To Fly" font:[BMGlyphFont fontWithName:@"ScoreFont"]];
		_tapToStartLabel.position = CGPointMake(size.width / 2, size.height * .65);
		[self addNode:_tapToStartLabel atWorldLayer:ABWorldLayerForeground];
		id blink = [SKAction sequence:@[[SKAction waitForDuration:.5],
		                                [SKAction fadeAlphaTo:0 duration:0.15],
		                                [SKAction waitForDuration:.5],
		                                [SKAction fadeAlphaTo:1.0 duration:.15]]];
		[_tapToStartLabel runAction:[SKAction repeatActionForever:blink]];

        ABCloud *cloud = [[ABCloud alloc] initAtPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))];
        [self.scene addChild:cloud];
        NSLog(@"%@", NSStringFromCGPoint(cloud.position));

	}
	return self;
}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.gameStarted && ![_playerCharacter paralyzed]) {
		[self startGame];
	}
	if (self.gameStarted) {
		[_playerCharacter move];
	}
}

- (void)startGame {
	[_tapToStartLabel removeAllActions];
	[_tapToStartLabel runAction:[SKAction fadeAlphaTo:0 duration:.5]];
	_gameStarted  = YES;
	if ([self.gameSceneDelegate respondsToSelector:@selector(gameDidStart)]) {
		[self.gameSceneDelegate gameDidStart];
	}
	_player.score = 0;
	_highscoreLabel.hidden = YES;
	SKTEffect *moveToEffect = [SKTMoveEffect effectWithNode:_scoreLabel
	                                               duration:.5
	                                          startPosition:_scoreLabel.position
	                                            endPosition:CGPointMake(self.size.width / 2, self.size.height * .9)];
	moveToEffect.timingFunction = SKTTimingFunctionCubicEaseOut;

	[_scoreLabel runAction:[SKAction actionWithEffect:moveToEffect]];
}

- (void)endGame {
	_gameStarted = NO;
	id blink = [SKAction sequence:@[[SKAction waitForDuration:.5],
	                                [SKAction fadeAlphaTo:0 duration:0.15],
	                                [SKAction waitForDuration:.5],
	                                [SKAction fadeAlphaTo:1.0 duration:.15]]];
	[_tapToStartLabel runAction:[SKAction repeatActionForever:blink]];
	if ([self.gameSceneDelegate respondsToSelector:@selector(gameDidEnd)]) {
		[self.gameSceneDelegate gameDidEnd];
	}
	[self prepareForDeath];
	_endingGame = NO;
	_highscoreLabel.hidden = NO;

	[_scoreLabel removeAllActions];
	SKTEffect *moveToEffect = [SKTMoveEffect effectWithNode:_scoreLabel
	                                               duration:.8
	                                          startPosition:_scoreLabel.position
	                                            endPosition:CGPointMake(self.size.width / 2, self.size.height * .35)];
	moveToEffect.timingFunction = SKTTimingFunctionCubicEaseOut;

	[_scoreLabel runAction:[SKAction actionWithEffect:moveToEffect]];
	_scoreLabel.text = [NSString stringWithFormat:@"%d", _player.score];
	_highscoreLabel.text = [NSString stringWithFormat:@"Highscore: %d", _player.highscore];

	[_playerCharacter revive];
}

- (void)spawnObject {
	NSUInteger i = 0;
	for (ABGameCharacter *character in _gameCharacters.mutableCopy) {
		if (!character.characterScene) {
			i = [_gameCharacters indexOfObject:character];
			[_gameCharacters removeObjectAtIndex:i];
			[_gameCharacters insertObject:character atIndex:_gameCharacters.count - 1];
			CGPoint playerCharacterPosition = _playerCharacter.position;
			[character reset];
			[character runAction:[SKAction scaleTo:abRand(.5, 1.0) duration:0]];
			[character addToScene:self atPosition:CGPointMake(self.size.width + character.size.width,
			                                                  playerCharacterPosition.y * abRand(0, 3.0))];
			return;
		}
	}
}

- (void)update:(NSTimeInterval)currentTime {
	NSTimeInterval delta = currentTime - _lastTime;
	_lastTime = currentTime;

	ABStarField *starField = (ABStarField *)[_worldLayers[ABWorldLayerStars] childNodeWithName:@"starField"];
	[starField update:delta];

	if (_gameStarted && !_endingGame) {
		// Create game characters
		_spawnCoolDown -= delta;
		if (_spawnCoolDown <= 0) {
			_spawnCoolDown = kSpawnCoolDown;
			[self spawnObject];
		}
		_scoreLabel.text = [NSString stringWithFormat:@"%d", [ABPlayer sharedPlayer].score];
	}

	[_playerCharacter update:delta];

	for (ABGameCharacter *gameCharacter in _gameCharacters) {
		[gameCharacter update:delta];

		if (_gameStarted) {
			if ([gameCharacter.name isEqualToString:@"cloud"] && gameCharacter.characterScene == self) {
				ABCloud *cloud = (ABCloud *)gameCharacter;
				if (!cloud.hasPassedPlayerCharacter) {
					BOOL passedPlayer = cloud.position.x + cloud.size.width / 2 <
					    _playerCharacter.position.x - _playerCharacter.size.width / 2;
					if (passedPlayer) {
						[cloud setPassedPlayerCharacter:YES];
						if (_gameStarted) {
							[ABPlayer sharedPlayer].score += 1;
						}
					}
				}
			}
		}
	}


	if (_playerCharacter.status == ABGameCharacterStatusDying) {
		[self prepareForDeath];
	}

	if (_playerCharacter.status == ABGameCharacterStatusDead) {
		[self endGame];
	}
}

- (void)prepareForDeath {
	_endingGame = YES;
	[_gameCharacters makeObjectsPerformSelector:@selector(performDeath)];
}

- (void)didSimulatePhysics {
	CGFloat offset = _playerCharacter.position.y - self.size.height * .65;
	if (offset > 0) {
		float score = offset / (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 8.0 : 4.0);
		if (floor(score) > 0) {
			[_scoreLabel runAction:[SKAction scaleTo:1.2 duration:.1]];
		}
		_player.score += score;

		[_playerCharacter setPosition:CGPointMake(_playerCharacter.position.x,
		                                          self.size.height * .65)];
		for (ABGameCharacter *character in _gameCharacters) {
			if (character.characterScene) {
				CGPoint newPosition = character.position;
				character.position = CGPointMake(newPosition.x, newPosition.y - offset);
			}
		}
	}
	else {
		[_scoreLabel runAction:[SKAction scaleTo:1.0 duration:.1]];
	}
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
	ABGameCharacter *gameChacaterA = (ABGameCharacter *)contact.bodyA.node;
	ABGameCharacter *gameChacaterB = (ABGameCharacter *)contact.bodyB.node;
	[gameChacaterA collideWith:contact.bodyB];
	[gameChacaterB collideWith:contact.bodyA];
}

- (void)addNode:(SKNode *)node atWorldLayer:(ABWorldLayer)worldLayer {
	SKNode *worldLayerNode = [_worldLayers objectAtIndex:worldLayer];
	[worldLayerNode addChild:node];
}

@end
