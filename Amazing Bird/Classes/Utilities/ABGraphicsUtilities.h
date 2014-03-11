//
//  ABGraphicsUtilities.h
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 27/02/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABGraphicsUtilities : NSObject

+ (NSArray *) loadFramesFromAtlas:(NSString *)atlas baseName:(NSString *)baseName;

@end