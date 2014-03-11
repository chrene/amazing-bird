//
//  SKNode+enumerateRecursively.m
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 27/02/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "SKNode+enumerateRecursively.h"

@implementation SKNode (enumerateRecursively)

- (NSArray *)allNodesRecursively {
	NSMutableArray *allNodes = [NSMutableArray array];
	for (SKNode *node in self.children) {
		[allNodes addObject:node];
		if (node.children.count > 0) {
			[allNodes addObjectsFromArray:[node allNodesRecursively]];
		}
	}
	return allNodes;
}

@end
