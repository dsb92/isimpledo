//
//  AddToDoItemViewController.m
//  iOSDoToList
//
//  Created by David Buhauer on 17/01/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "AddToDoItemViewController.h"
#import "ReminderViewController.h"
#import "SelectionListViewController.h"
#import "Utility.h"
#import "DateWrapper.h"
#import "LocalNotifications.h"

@interface AddToDoItemViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *dueDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *reminderButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Is private and thats why it's not declared in .h file.
@end

@implementation AddToDoItemViewController
@synthesize toDoItem;


#pragma mark - IBActions

-(IBAction)cancelFromReminder:(UIStoryboardSegue*) segue{
    [self updateHighlightForReminderButton];
}

-(IBAction)unWindFromReminder:(UIStoryboardSegue*) segue{
    ReminderViewController *reminderViewController = (ReminderViewController*)  self.reminderViewController;
    
    self.toDoItem = reminderViewController.toDoItem;
    
    self.toDoItem = reminderViewController.toDoItem;
    self.toDoItem.itemName = reminderViewController.itemname;
    self.toDoItem.alertSelection = reminderViewController.alertDetail;
    self.toDoItem.repeatSelection = reminderViewController.repeatDetail;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    // get datepicker end value
    NSDate *choice = [reminderViewController.reminderPicker date];
    NSString *endDate = [dateFormatter stringFromDate:choice];
    self.toDoItem.endDate = endDate;
    self.toDoItem.actualEndDate = choice;
    
    self.dueDateLabel.text = endDate;
    
    self.isNotifyOn = reminderViewController.mainSwitch.isOn;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.reminderButton setHighlighted:YES];
}

-(IBAction)unWindFromSelectionList:(UIStoryboardSegue*) segue{
    SelectionListViewController *selectionViewController = [segue sourceViewController];
    self.selectedKey = selectionViewController.selectedKey;
    [self.tableView reloadData];
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
        [self updateHighlightForReminderButton];
    }
    else
        self.reminderButton.hidden = YES;
}

#pragma mark - didLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.listArray = [[NSMutableArray alloc]initWithObjects:@"Lists", nil];
    
    if (self.isFilter){
        self.tableView.hidden = NO;
    }
    else
        self.tableView.hidden = YES;
    
    self.dueDateLabel.clearButtonMode = UITextFieldViewModeAlways;
    
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
        else
            [self.reminderButton setHighlighted:NO];
    }
    else{
        self.toDoItem = [[ToDoItem alloc] init];

        self.toDoItem.itemid = [Utility generateUniqID];
        self.toDoItem.listKey = self.selectedKey;
        
        [self.textField becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = self.selectedKey;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"SelectionListSegue" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"List";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Set the text color of our header/footer text.
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]];
    
    // Set the background color of our header/footer.
    //header.contentView.backgroundColor = [UIColor blackColor];
    
    // You can also do this to set the background color of our header/footer,
    //    but the gradients/other effects will be retained.
    // view.tintColor = [UIColor blackColor];
}

#pragma mark - Private functions

-(void)updateHighlightForReminderButton{
    if(self.isInEditMode && [self.toDoItem.endDate length] != 0)
        [self.reminderButton setHighlighted:YES];
    else
        [self.reminderButton setHighlighted:NO];
}


#pragma mark - UITextfield delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if (self.dueDateLabel.text.length == 0){
        self.toDoItem.endDate = nil;
        self.toDoItem.alertSelection = nil;
        self.toDoItem.repeatSelection = nil;
        [LocalNotifications cancelLocalNotification:self.toDoItem];
    }
    
    // If user presses reminder button
    if (sender == self.reminderButton)
    {
        UINavigationController *navController = [segue destinationViewController];
        ReminderViewController *reminderVIewController = (ReminderViewController*)[navController topViewController];
        self.reminderViewController = reminderVIewController;
        reminderVIewController.addToDoViewController = self;
        self.toDoItem.completed = false;
        if(self.isInEditMode)
            reminderVIewController.isInEditMode = YES;
        else
            self.toDoItem.creationDate = [DateWrapper getCurrentDate];
        
        reminderVIewController.toDoItem = self.toDoItem;
        reminderVIewController.itemname = self.textField.text;
        reminderVIewController.isShortcut = NO;
        
        return;
    }
    else if ([segue.identifier isEqualToString:@"SelectionListSegue"]){
        SelectionListViewController *selectionViewController = [segue destinationViewController];
        selectionViewController.customListDictionary = self.customListDictionary;
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
        if(self.isInEditMode && [self.toDoItem.endDate length] != 0)
            [LocalNotifications cancelLocalNotification:self.toDoItem];
        self.toDoItem.itemName = self.textField.text;
        self.toDoItem.completed = false;
    }
    
    if (self.isInEditMode == NO)
        self.toDoItem.creationDate = [DateWrapper getCurrentDate];

}

@end
