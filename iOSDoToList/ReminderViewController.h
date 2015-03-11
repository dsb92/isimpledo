//
//  ReminderViewController.h
//  iOSDoToList
//
//  Created by David Buhauer on 02/02/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoItem.h"

@interface ReminderViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *setButton;
@property ToDoItem *toDoItem;
@property NSString *alertDetail;
@property NSString *repeatDetail;
@property NSArray *reminderTableViewArray;
@property BOOL isInEditMode;
@property BOOL isShortcut;
@property BOOL didCancel;
@property BOOL hasNotification;
@property UISwitch *mainSwitch;
-(NSString*)getReminderDate;

-(IBAction)rightButtonAction:(id)sender;
-(IBAction)unWindFromAlert:(UIStoryboardSegue*) segue;
-(IBAction)unWindFromRepeat:(UIStoryboardSegue*) segue;
-(IBAction)reminderDateChanged:(id)sender;

@end
