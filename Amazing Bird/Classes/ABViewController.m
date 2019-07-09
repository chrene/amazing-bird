//
//  ABViewController.m
//  Amazing Bird
//
//  Created by ChristianEnevoldsen on 24/02/14.
//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import "ABViewController.h"

@implementation ABViewController {
	ABGameScene *_runningScene;
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
	// Configure the view.
	SKView *skView = (SKView *)self.view;
	if (!skView.scene) {
		SKScene *scene = [ABGameScene sceneWithSize:skView.bounds.size];
		scene.scaleMode = SKSceneScaleModeResizeFill;
    [skView setShowsFPS:YES];
    [skView setShowsNodeCount:YES];
		[skView presentScene:scene];
		_runningScene = (ABGameScene *)scene;
    _runningScene.gameSceneDelegate = self;
	}
}

- (void)gameDidEnd {
    
}

- (void)gameDidStart {
    
}

- (BOOL)shouldAutorotate {
	return YES;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (_runningScene) {
        if (_runningScene.gameStarted) {
            return UIInterfaceOrientationMaskLandscape;
        }
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
}

@end
