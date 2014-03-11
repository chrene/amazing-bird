//
//  ABPlayer.m
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 26/02/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "ABPlayer.h"

@implementation ABPlayer

static ABPlayer *_sharedPlayer;

+ (instancetype)sharedPlayer
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedPlayer = [[self alloc] init];
	});
	return _sharedPlayer;
}

#pragma mark - Creation

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.score = 0;
		self.highscore = 0;
		self.premium = NO;
	}
	return self;
}

- (void)setScore:(int)score
{
	_score = score;
	_highscoreChanged = _score > _highscore;
	_highscore = MAX(_highscore, _score);
}

@end
