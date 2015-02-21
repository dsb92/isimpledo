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
@property (weak, nonatomic) IBOutlet UIPickerView *priorityPicker;
@property (weak, nonatomic) IBOutlet UIButton *priorityButton;
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

-(IBAction)setDueDate:(id)sender{
    UIButton *dueButton = (UIButton*)sender;
    dueButton.selected = !dueButton.selected;
    if (dueButton.selected) {
        self.datePicker.hidden = NO;
        [sender setTitle:@"Hide due date" forState:UIControlStateSelected];
    }
    else {
        self.datePicker.hidden = YES;
        [sender setTitle:@"Set due date" forState:UIControlStateNormal];
    }
}

-(IBAction)setPriority:(id)sender{
    UIButton *priorityButton = (UIButton*)sender;
    priorityButton.selected = !priorityButton.selected;
    if (priorityButton.selected) {
        self.priorityPicker.hidden = NO;
        [sender setTitle:@"Hide priority" forState:UIControlStateSelected];
    }
    else {
        self.priorityPicker.hidden = YES;
        [sender setTitle:@"Set priority" forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *priorities = [[NSArray alloc] initWithObjects:@"HIGH", @"MED", @"LOW", nil];
    self.priorityArray = priorities;
    
    if (self.isInEditMode) {
        // Show item name of item
        self.textField.text = self.toDoItem.itemName;
        
        // Show due date of item
        if(self.toDoItem.endDate != nil){
            self.dueDateLabel.text = self.toDoItem.endDate;
            [self.reminderButton setTitle:@"Edit reminder" forState:UIControlStateNormal];
        }
        
        // Show priority of item
        if ([self.toDoItem.priority isEqualToString:@"HIGH"]) {
            [self.priorityPicker selectRow:0 inComponent:0 animated:YES];
        }
        else if ([self.toDoItem.priority isEqualToString:@"MED"]) {
            [self.priorityPicker selectRow:1 inComponent:0 animated:YES];
        }
        if ([self.toDoItem.priority isEqualToString:@"LOW"]) {
            [self.priorityPicker selectRow:2 inComponent:0 animated:YES];
        }
        self.priorityPicker.hidden = NO;
        self.priorityButton.selected = YES;
        [self.priorityButton setTitle:@"Hide priority" forState:UIControlStateSelected];
    }
    else{
        self.toDoItem = [[ToDoItem alloc] init];
        
        [self.priorityPicker selectRow:1 inComponent:0 animated:YES];
        
        [self.textField becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

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
        self.toDoItem.itemName = self.textField.text;
        self.toDoItem.completed = false;
    }
    
    if (self.isInEditMode == NO)
        self.toDoItem.creationDate = self.getCurrentDate;
    
    // get pririoty from priorioty wheel
    NSInteger row = [self.priorityPicker selectedRowInComponent:0];
    NSString *priority = [self.priorityArray objectAtIndex:row];
    self.toDoItem.priority = priority;
    
    // print out item
    NSLog(@"Priority: %@\n, Itemname: %@\n, Creationdate: %@\n, Enddate: %@\n, Alert: %@\n, Repeat: %@\n", self.toDoItem.priority, self.toDoItem.itemName, self.toDoItem.creationDate, self.toDoItem.endDate, self.toDoItem.alertSelection, self.toDoItem.repeatSelection);
}

#pragma mark - Priority wheel

// How many wheels?
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// How many choices?
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.priorityArray count];
}

// Titel for each choice
-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.priorityArray objectAtIndex:row];
}


@end
