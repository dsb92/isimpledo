//
//  RepeatViewController.h
//  iOSDoToList
//
//  Created by David Buhauer on 07/02/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepeatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property NSArray *repeatArray;
@property NSString* repeatSelection;

@end
