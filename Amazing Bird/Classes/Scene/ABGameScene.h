//
//  ABMyScene.h
//  Amazing Bird
//

//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class ABGameCharacter;

typedef enum : uint8_t {
	ABWorldLayerBackground = 0,
	ABWorldLayerStars,
	ABWorldLayerGameCharacters,
	ABWorldLayerForeground,
	ABWorldLayerCount
} ABWorldLayer;

@protocol ABGameSceneDelegate <NSObject>
@optional
- (void)gameDidStart;
- (void)gameDidEnd;
@end



@interface ABGameScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic, assign, readonly) BOOL gameStarted;

- (void)addNode:(SKNode *)node atWorldLayer:(ABWorldLayer)worldLayer;

@property (nonatomic, weak) id <ABGameSceneDelegate> gameSceneDelegate;

@end
