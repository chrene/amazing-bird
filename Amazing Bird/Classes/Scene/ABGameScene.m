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

#define kSpawnCoolDown UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? .12 : .17

// Fraction of screen height the player is locked to while the camera scrolls up.
// 0.65 means the player sits 65% up the visible area during active play.
static const CGFloat kPlayerScreenFraction = 0.65;

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
	SKCameraNode *_camera;
	ABStarField *_starField;
	BOOL _scoreLabelIsScaledUp;
	int _displayedScore;
}

- (id)initWithSize:(CGSize)size {
	if (self = [super initWithSize:size]) {

		_spawnCoolDown = kSpawnCoolDown;

		[ABNormalBird loadSharedFrames];

		// Camera — HUD labels are added as children so they stay screen-fixed
		// while the camera tracks the player upward.
		// In camera-local space: origin = screen center, +y = up.
		_camera = [SKCameraNode node];
		_camera.position = CGPointMake(size.width / 2, size.height / 2);
		[self addChild:_camera];
		self.camera = _camera;

		// Physics world
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.physicsWorld.gravity = CGVectorMake(0, -11);
		} else {
			self.physicsWorld.gravity = CGVectorMake(0, -5.5);
		}
		self.physicsWorld.contactDelegate = self;

		// Player model
		_player = [ABPlayer sharedPlayer];

		// World layers
		_worldLayers = [NSMutableArray arrayWithCapacity:ABWorldLayerCount];
		for (int i = 0; i < ABWorldLayerCount; ++i) {
			SKNode *worldLayer = [SKNode node];
			worldLayer.zPosition = i;
			[self addChild:worldLayer];
			[_worldLayers addObject:worldLayer];
		}

		// Background
		SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
		SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"Background"]];
		background.position = CGPointZero;   // camera-local: (0,0) = screen center
		background.size = size;
		background.zPosition = ABWorldLayerBackground;
		[_camera addChild:background];

		// HUD labels — children of _camera; positions in camera-local space.
		// Conversion from original scene coords: camera_y = scene_y - size.height/2
		_scoreLabel = [BMGlyphLabel labelWithText:@"0" font:[BMGlyphFont fontWithName:@"ScoreFont"]];
		_scoreLabel.position = CGPointMake(0, size.height * 0.6);   // off-screen above initially
		[_camera addChild:_scoreLabel];

		_highscoreLabel = [BMGlyphLabel labelWithText:[NSString stringWithFormat:@"Highscore: %d", _player.highscore]
		                                         font:[BMGlyphFont fontWithName:@"ScoreFont"]];
		_highscoreLabel.position = CGPointMake(0, -size.height * 0.25);
		[_camera addChild:_highscoreLabel];

		// Player character
		_playerCharacter = [[ABNormalBird alloc] initAtPosition:CGPointMake(size.width / 2, size.height / 2)
		                                             withPlayer:_player];
		[_playerCharacter addToScene:self atPosition:CGPointMake(size.width / 2, size.height / 2)];
		[_playerCharacter idle];
		[_playerCharacter.physicsBody setUsesPreciseCollisionDetection:YES];

		// Cloud pool
		int maxClouds = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 30 : 25;
		NSMutableArray *gameCharacters = [NSMutableArray arrayWithCapacity:maxClouds];
		for (int i = 0; i < maxClouds; i++) {
			[gameCharacters addObject:[[ABCloud alloc] initAtPosition:CGPointZero]];
		}
		_gameCharacters = [NSMutableArray arrayWithArray:gameCharacters];

		// Star field — camera child so it stays screen-fixed as the camera scrolls up.
		// Positioned at bottom-left of camera space so its (0,0) origin aligns with
		// the screen's bottom-left corner, matching the layout of its internal star nodes.
		_starField = [[ABStarField alloc] initWithSize:size];
		_starField.name = @"starField";
		_starField.position = CGPointMake(-size.width / 2, -size.height / 2);
		_starField.zPosition = ABWorldLayerStars;  // between background and game characters
		[_camera addChild:_starField];

		// Tap-to-start label
		_tapToStartLabel = [BMGlyphLabel labelWithText:@"Tap To Fly" font:[BMGlyphFont fontWithName:@"ScoreFont"]];
		_tapToStartLabel.position = CGPointMake(0, size.height * 0.15);  // 65% up screen in camera space
		[_camera addChild:_tapToStartLabel];
		[_tapToStartLabel runAction:[self tapToStartBlinkAction]];
	}
	return self;
}

- (SKAction *)tapToStartBlinkAction
{
	id blink = [SKAction sequence:@[[SKAction waitForDuration:.5],
	                                [SKAction fadeAlphaTo:0 duration:0.15],
	                                [SKAction waitForDuration:.5],
	                                [SKAction fadeAlphaTo:1.0 duration:.15]]];
	return [SKAction repeatActionForever:blink];
}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!self.gameStarted && ![_playerCharacter paralyzed]) {
		[self startGame];
	}
	if (self.gameStarted) {
		[_playerCharacter move];
	}
}

- (void)startGame
{
	[_tapToStartLabel removeAllActions];
	[_tapToStartLabel runAction:[SKAction fadeAlphaTo:0 duration:.5]];
	_gameStarted = YES;
	_player.score = 0;
	_displayedScore = 0;
	_scoreLabelIsScaledUp = NO;
	_highscoreLabel.hidden = YES;
	SKTEffect *moveToEffect = [SKTMoveEffect effectWithNode:_scoreLabel
	                                               duration:.5
	                                          startPosition:_scoreLabel.position
	                                            endPosition:CGPointMake(0, self.size.height * 0.4)];
	moveToEffect.timingFunction = SKTTimingFunctionCubicEaseOut;
	[_scoreLabel runAction:[SKAction actionWithEffect:moveToEffect]];
}

- (void)endGame
{
	_gameStarted = NO;
	_scoreLabelIsScaledUp = NO;
	[_tapToStartLabel removeAllActions];
	_tapToStartLabel.alpha = 1.0;
	[_tapToStartLabel runAction:[self tapToStartBlinkAction]];
	[self prepareForDeath];
	_endingGame = NO;
	_highscoreLabel.hidden = NO;

	[_scoreLabel removeAllActions];
	SKTEffect *moveToEffect = [SKTMoveEffect effectWithNode:_scoreLabel
	                                               duration:.8
	                                          startPosition:_scoreLabel.position
	                                            endPosition:CGPointMake(0, -self.size.height * 0.15)];
	moveToEffect.timingFunction = SKTTimingFunctionCubicEaseOut;
	[_scoreLabel runAction:[SKAction actionWithEffect:moveToEffect]];
	_scoreLabel.text = [NSString stringWithFormat:@"%d", _player.score];
	_highscoreLabel.text = [NSString stringWithFormat:@"Highscore: %d", _player.highscore];

	[_playerCharacter revive];
}

- (void)spawnObject
{
	NSUInteger i = 0;
	for (ABGameCharacter *character in _gameCharacters.mutableCopy) {
		if (!character.characterScene) {
			i = [_gameCharacters indexOfObject:character];
			[_gameCharacters removeObjectAtIndex:i];
			[_gameCharacters insertObject:character atIndex:_gameCharacters.count - 1];
			[character reset];
			[character runAction:[SKAction scaleTo:abRand(.5, 1.0) duration:0]];
			CGPoint playerCharacterPosition = _playerCharacter.position;
			[character addToScene:self atPosition:CGPointMake(self.size.width + character.size.width, playerCharacterPosition.y * abRand(0, 3.0))];
			return;
		}
	}
}

- (void)update:(NSTimeInterval)currentTime
{
	// Skip the first frame: _lastTime is 0 and delta would be seconds since device boot,
	// causing a massive initial spawn and physics tick.
	if (_lastTime == 0) {
		_lastTime = currentTime;
		return;
	}

	NSTimeInterval delta = currentTime - _lastTime;
	_lastTime = currentTime;

	[_starField update:delta];

	if (_gameStarted && !_endingGame) {
		_spawnCoolDown -= delta;
		if (_spawnCoolDown <= 0) {
			_spawnCoolDown = kSpawnCoolDown;
			[self spawnObject];
		}
		// Only reallocate the label string when the integer score actually changes
		int currentScore = (int)[ABPlayer sharedPlayer].score;
		if (currentScore != _displayedScore) {
			_displayedScore = currentScore;
			_scoreLabel.text = [NSString stringWithFormat:@"%d", currentScore];
		}
	}

	[_playerCharacter update:delta];

	for (ABGameCharacter *gameCharacter in _gameCharacters) {
		[gameCharacter update:delta];

		if (_gameStarted) {
			// _gameCharacters contains only ABCloud instances; no name check needed
			ABCloud *cloud = (ABCloud *)gameCharacter;
			if (cloud.characterScene == self && !cloud.hasPassedPlayerCharacter) {
				BOOL passedPlayer = cloud.position.x + cloud.size.width / 2 <
				    _playerCharacter.position.x - _playerCharacter.size.width / 2;
				if (passedPlayer) {
					[cloud setPassedPlayerCharacter:YES];
					[ABPlayer sharedPlayer].score += 1;
				}
			}
		}
	}

	// Guard with !_endingGame: once prepareForDeath is called it sets _endingGame = YES,
	// preventing performDeath from being spammed on every subsequent frame.
	if (_playerCharacter.status == ABGameCharacterStatusDying && !_endingGame) {
		[self prepareForDeath];
	}

	if (_playerCharacter.status == ABGameCharacterStatusDead) {
		[self endGame];
	}
}

- (void)prepareForDeath
{
	_endingGame = YES;
	[_gameCharacters makeObjectsPerformSelector:@selector(performDeath)];
}

- (void)didSimulatePhysics
{
	// The camera stays fixed; scrolling is achieved by clamping the player to
	// kPlayerScreenFraction of the screen and shifting all world objects down.
	// Moving the camera would decouple the bird's world-y from the cloud world-y,
	// breaking contact detection (bird at y=10000, clouds at y=300 → never intersect).
	CGFloat targetPlayerY = self.size.height * kPlayerScreenFraction;
	CGFloat offset = _playerCharacter.position.y - targetPlayerY;

	if (offset > 0) {
		float score = offset / (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 8.0 : 4.0);
		_player.score += score;

		// Clamp player back to target and pull all active world objects down by the same offset
		[_playerCharacter setPosition:CGPointMake(_playerCharacter.position.x, targetPlayerY)];
		for (ABGameCharacter *character in _gameCharacters) {
			if (character.characterScene) {
				character.position = CGPointMake(character.position.x, character.position.y - offset);
			}
		}

		// Pulse the score label only on the transition, not every frame
		if (floor(score) > 0 && !_scoreLabelIsScaledUp) {
			[_scoreLabel removeAllActions];
			[_scoreLabel runAction:[SKAction scaleTo:1.2 duration:.1]];
			_scoreLabelIsScaledUp = YES;
		}
	} else if (_scoreLabelIsScaledUp) {
		[_scoreLabel removeAllActions];
		[_scoreLabel runAction:[SKAction scaleTo:1.0 duration:.1]];
		_scoreLabelIsScaledUp = NO;
	}
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact
{
	ABGameCharacter *gameChacaterA = (ABGameCharacter *)contact.bodyA.node;
	ABGameCharacter *gameChacaterB = (ABGameCharacter *)contact.bodyB.node;
	[gameChacaterA collideWith:contact.bodyB];
	[gameChacaterB collideWith:contact.bodyA];
}

- (void)addNode:(SKNode *)node atWorldLayer:(ABWorldLayer)worldLayer
{
	SKNode *worldLayerNode = [_worldLayers objectAtIndex:worldLayer];
	[worldLayerNode addChild:node];
}

@end
