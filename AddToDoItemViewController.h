//
//  AddToDoItemViewController.h
//  iOSDoToList
//
//  Created by David Buhauer on 17/01/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoItem.h"

@interface AddToDoItemViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property ToDoItem *toDoItem;
@property BOOL isInEditMode;
@property BOOL didCancel;
@property NSString *selectedKey;

@property NSMutableArray *listArray;
@property NSMutableDictionary *customListDictionary;
@property UIViewController *reminderViewController;
@property BOOL isNotifyOn;
@property BOOL isFilter;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;

-(IBAction)cancelFromReminder:(UIStoryboardSegue*) segue;
-(IBAction)unWindFromReminder:(UIStoryboardSegue*) segue;
-(IBAction)unWindFromSelectionList:(UIStoryboardSegue*) segue;
-(IBAction)hideKeyboard:(id)sender;
-(IBAction)tapBackground:(id)sender;
-(IBAction)textChanged:(id)sender;

@end
