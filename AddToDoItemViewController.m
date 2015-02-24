//
//  AddToDoItemViewController.m
//  iOSDoToList
//
//  Created by David Buhauer on 17/01/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "AddToDoItemViewController.h"
#import "ReminderViewController.h"

@interface AddToDoItemViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *reminderButton;

// Is private and thats why it's not declared in .h file.
@end

@implementation AddToDoItemViewController

@synthesize toDoItem;

-(NSString*)getCurrentDate{
    // get current date/time value
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    return currentTime;
}

-(IBAction)unWindFromReminder:(UIStoryboardSegue*) segue{
    //Retreive the source view controller (EditToItemViewController) and get the data from it
    ReminderViewController *source = [segue sourceViewController];
    
    self.toDoItem.endDate = source.toDoItem.endDate;
    
    NSString *currentTime = self.getCurrentDate;
    
    if (![currentTime isEqualToString:self.toDoItem.endDate] && self.toDoItem.endDate != nil) {
        self.dueDateLabel.text = self.toDoItem.endDate;
        [self.reminderButton setTitle:@"Edit reminder" forState:UIControlStateNormal];
    }
}

-(IBAction)hideKeyboard:(id)sender{
    [sender resignFirstResponder];
}
-(IBAction)tapBackground:(id)sender{
    [self.textField resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (self.isInEditMode) {
        // Show item name of item
        self.textField.text = self.toDoItem.itemName;
        
        // Show due date of item
        if(self.toDoItem.endDate != nil){
            self.dueDateLabel.text = self.toDoItem.endDate;
            [self.reminderButton setTitle:@"Edit reminder" forState:UIControlStateNormal];
        }
    }
    else{
        self.toDoItem = [[ToDoItem alloc] init];

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
        if([[localN.userInfo objectForKey:@"name"] isEqualToString:item.itemName]){
            [[UIApplication sharedApplication] cancelLocalNotification:localN];
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
        self.toDoItem.creationDate = self.getCurrentDate;

    // print out item
    NSLog(@"Itemname: %@\n, Creationdate: %@\n, Enddate: %@\n, Alert: %@\n, Repeat: %@\n", self.toDoItem.itemName, self.toDoItem.creationDate, self.toDoItem.endDate, self.toDoItem.alertSelection, self.toDoItem.repeatSelection);
}

@end
