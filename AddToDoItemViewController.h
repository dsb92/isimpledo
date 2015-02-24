//
//  AddToDoItemViewController.h
//  iOSDoToList
//
//  Created by David Buhauer on 17/01/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoItem.h"

@interface AddToDoItemViewController : UIViewController

@property ToDoItem *toDoItem;
@property BOOL isInEditMode;
@property BOOL didCancel;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;

-(NSString*)getCurrentDate;

-(IBAction)unWindFromReminder:(UIStoryboardSegue*) segue;
-(IBAction)hideKeyboard:(id)sender;
-(IBAction)tapBackground:(id)sender;

@end
