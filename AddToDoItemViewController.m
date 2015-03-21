//
//  AddToDoItemViewController.m
//  iOSDoToList
//
//  Created by David Buhauer on 17/01/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "AddToDoItemViewController.h"
#import "ReminderViewController.h"
#import "Utility.h"
#import "DateWrapper.h"

@interface AddToDoItemViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *reminderButton;

// Is private and thats why it's not declared in .h file.
@end

@implementation AddToDoItemViewController

@synthesize toDoItem;

-(IBAction)cancelFromReminder:(UIStoryboardSegue*) segue{
    [self.reminderButton setHighlighted:YES];
}

-(IBAction)hideKeyboard:(id)sender{
    [sender resignFirstResponder];
}
-(IBAction)tapBackground:(id)sender{
    [self.textField resignFirstResponder];
}

-(IBAction)textChanged:(id)sender{
    if (self.textField.text.length > 0) {
        self.reminderButton.hidden = NO;
        if(self.isInEditMode)
            [self.reminderButton setHighlighted:YES];
        else
            [self.reminderButton setHighlighted:NO];
    }
    else
        self.reminderButton.hidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(self.textField.text.length > 0 || (self.toDoItem.itemName != nil && self.toDoItem.itemName.length > 0))
        self.reminderButton.hidden = NO;
    else
        self.reminderButton.hidden = YES;
    
    if (self.isInEditMode) {
        // Show item name of item
        self.textField.text = self.toDoItem.itemName;
        
        // Show due date of item
        if([self.toDoItem.endDate length] != 0){
            NSString *date = [DateWrapper wrapDate:self.toDoItem.endDate];
            self.dueDateLabel.text = date;
            [self.reminderButton setHighlighted:YES];
        }
    }
    else{
        self.toDoItem = [[ToDoItem alloc] init];

        toDoItem.itemid = [Utility generateUniqID];
        
        [self.textField becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

-(void) cancelLocalNotification:(ToDoItem*)item{
    for(UILocalNotification *localN in [[UIApplication sharedApplication]scheduledLocalNotifications]){
        if([[localN.userInfo objectForKey:@"itemid"] isEqualToString:item.itemid]){
            [[UIApplication sharedApplication] cancelLocalNotification:localN];
            NSLog(@"Notification canceled");
            return;
        }
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    // If user presses reminder button
    if (sender == self.reminderButton)
    {
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        ReminderViewController *reminderVIewController = (ReminderViewController*)[navController topViewController];
        self.toDoItem.itemName = self.textField.text;
        self.toDoItem.completed = false;
        
        if(self.isInEditMode)
            reminderVIewController.isInEditMode = YES;
        else
            self.toDoItem.creationDate = [DateWrapper getCurrentDate];
        
        reminderVIewController.toDoItem = self.toDoItem;
    }
    
    // If user did not press save button, return.
    if (sender != self.saveButton)
    {
        self.didCancel = YES;
        return;
    }
    
    self.didCancel = NO;

    // User presses save button:
    
    // get to do item name from textfield
    if (self.textField.text.length > 0) {
        
        // Cancel any local notifaction attached to the old item name contained in dictionary.
        [self cancelLocalNotification:self.toDoItem];
        self.toDoItem.itemName = self.textField.text;
        self.toDoItem.completed = false;
    }
    
    if (self.isInEditMode == NO)
        self.toDoItem.creationDate = [DateWrapper getCurrentDate];

    // print out item
    NSLog(@"Itemid: %@\n, Itemname: %@\n, Creationdate: %@\n, Enddate: %@\n, Alert: %@\n, Repeat: %@\n", self.toDoItem.itemid, self.toDoItem.itemName, self.toDoItem.creationDate, self.toDoItem.endDate, self.toDoItem.alertSelection, self.toDoItem.repeatSelection);
}

@end
