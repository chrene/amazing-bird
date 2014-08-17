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

- (GADRequest *)request {
	GADRequest *request = [GADRequest request];
	return request;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setupAdBanner];
}

- (void)setupAdBanner {
	// Initialize banner view
	_bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];

	// Specify the ad unit id
	_bannerView.adUnitID = @"ca-app-pub-7657668557079113/8880231381";

	// Fallback to view controller
	_bannerView.rootViewController = self;
	[self.view addSubview:_bannerView];

	// Initiate a generic request to load it with an ad.
	[_bannerView loadRequest:[self request]];

	_bannerView.delegate = self;
}

- (void)viewDidLayoutSubviews {
	// Configure the view.
	SKView *skView = (SKView *)self.view;
	if (!skView.scene) {
		SKScene *scene = [ABGameScene sceneWithSize:skView.bounds.size];
		scene.scaleMode = SKSceneScaleModeResizeFill;
		[skView presentScene:scene];
		_runningScene = (ABGameScene *)scene;
        _runningScene.gameSceneDelegate = self;
	}
}

- (void)gameDidEnd {
    [self adViewDidDismissScreen:_bannerView];
}

- (void)gameDidStart {
    [self adViewWillDismissScreen:_bannerView];
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	if (_runningScene) {
		if (_runningScene.gameStarted) {
			return [[UIApplication sharedApplication] statusBarOrientation];
		}
	}
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return UIInterfaceOrientationMaskAllButUpsideDown;
	}
	else {
		return UIInterfaceOrientationMaskAll;
	}
}

#pragma mark - ABGameSceneDelegate

- (void)adViewWillDismissScreen:(GADBannerView *)adView {
	_bannerView.frame = CGRectMake(0, self.view.bounds.size.height - _bannerView.frame.size.height,
	                               _bannerView.frame.size.width, _bannerView.frame.size.height);
	[UIView beginAnimations:@"BannerSlideDown" context:nil];

	_bannerView.frame = CGRectMake(0, self.view.bounds.size.height,
	                               _bannerView.frame.size.width, _bannerView.frame.size.height);

	[UIView commitAnimations];
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    if (!_runningScene.gameStarted) {
        [_bannerView loadRequest:[self request]];
    }
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    if (_runningScene.gameStarted) {
        return;
    }
	_bannerView.frame = CGRectMake(0, self.view.bounds.size.height + _bannerView.bounds.size.height,
	                               _bannerView.frame.size.width, _bannerView.frame.size.height);
	[UIView beginAnimations:@"BannerSlide" context:nil];
	_bannerView.frame = CGRectMake(0, self.view.bounds.size.height - _bannerView.bounds.size.height,
	                               _bannerView.frame.size.width, _bannerView.frame.size.height);
	[UIView commitAnimations];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
	NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

@end
