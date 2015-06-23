//
//  GlobalListsViewController.h
//  SimpleDo
//
//  Created by David Buhauer on 18/06/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectionListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property NSMutableDictionary *customListDictionary;
@property NSString *selectedKey;
@end
