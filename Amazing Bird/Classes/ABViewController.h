//
//  ABViewController.h
//  Amazing Bird
//

//  Copyright (c) 2014 ChristianEnevoldsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GADBannerViewDelegate.h"
#import "GADBannerView.h"
#import "ABGameScene.h"

@interface ABViewController : UIViewController <GADBannerViewDelegate>

@property (nonatomic, readonly) GADBannerView *bannerView;

@end
