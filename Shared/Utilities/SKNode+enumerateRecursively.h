//
//  SKNode+enumerateRecursively.h
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 27/02/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKNode (enumerateRecursively)
- (NSArray *)allNodesRecursively;
@end
