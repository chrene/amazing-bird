//
//  ABStarField.h
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 08/03/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ABStarField : SKSpriteNode
- (instancetype)initWithSize:(CGSize)size;
- (void)update:(NSTimeInterval)delta;
@end
