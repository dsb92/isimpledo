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

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property ToDoItem *toDoItem;
@property BOOL isInEditMode;
@property NSString *selectedKey;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *dueDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *reminderButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *listArray;
@property UIViewController *viewController;
@property BOOL isNotifyOn;
@property BOOL isFilter;
@property BOOL isGlobal;

-(IBAction)cancelFromReminder:(UIStoryboardSegue*) segue;
-(IBAction)unWindFromReminder:(UIStoryboardSegue*) segue;
-(IBAction)unWindFromSelectionList:(UIStoryboardSegue*) segue;
-(IBAction)hideKeyboard:(id)sender;
-(IBAction)tapBackground:(id)sender;
-(IBAction)textChanged:(id)sender;

@end
