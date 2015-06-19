//
//  GlobalAddToDoItemViewController.h
//  SimpleDo
//
//  Created by David Buhauer on 18/06/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoItem.h"

@interface GlobalAddToDoItemViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property ToDoItem *toDoItem;
@property BOOL isInEditMode;
@property BOOL didCancel;

@property NSMutableArray *listArray;
@property NSMutableDictionary *customListDictionary;
@property NSString *selectedKey;
@property BOOL isNotifyOn;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;

-(IBAction)cancelFromReminder:(UIStoryboardSegue*) segue;
-(IBAction)hideKeyboard:(id)sender;
-(IBAction)tapBackground:(id)sender;
-(IBAction)textChanged:(id)sender;
@end
