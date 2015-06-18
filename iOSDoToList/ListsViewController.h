//
//  ListsViewController.h
//  SimpleDo
//
//  Created by David Buhauer on 17/05/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *filterArray;
@property NSMutableDictionary *customListDictionary;

@end
