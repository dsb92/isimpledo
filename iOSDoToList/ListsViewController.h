//
//  ListsViewController.h
//  SimpleDo
//
//  Created by David Buhauer on 17/05/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMobileAds;

@interface ListsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, GADInterstitialDelegate>

@property NSMutableArray *filterArray;
@property UIViewController *viewController;
@property NSString *selectedKey;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@end
