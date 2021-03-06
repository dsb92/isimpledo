//
//  ReminderViewController.m
//  iOSDoToList
//
//  Created by David Buhauer on 02/02/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "ReminderViewController.h"
#import "AlertViewController.h"
#import "RepeatViewController.h"
#import "ToDoListTableViewController.h"

@interface ReminderViewController () 
@property (strong, nonatomic) IBOutlet UITableView *reminderTableView;

@end

@implementation ReminderViewController

#pragma mark - didLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(self.isShortcut){
        [self.setButton setTarget:self.viewController];
        [self.setButton setAction:@selector(unWindFromShortCut:)];
        [self.cancelButton setTarget:self.viewController];
        [self.cancelButton setAction:@selector(unWindFromShortCut:)];
    }
    else{
        [self.setButton setTarget:self.viewController];
        [self.setButton setAction:@selector(unWindFromReminder:)];
        [self.cancelButton setTarget:self.viewController];
        [self.cancelButton setAction:@selector(cancelFromReminder:)];
    }
    
    self.reminderTableViewArray = [[NSArray alloc]initWithObjects:@"Alert", @"Repeat", @"Remind", nil];
    
    [self.reminderPicker setMinimumDate:[NSDate date]];
    
    if([self.toDoItem.endDate length] != 0 )
    {
        // set datepicker end value
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
        NSDate *date = [dateFormatter dateFromString:self.toDoItem.endDate];
        self.reminderPicker.date = date;
    }
    
    if ([self.toDoItem.alertSelection length] != 0){
        self.alertDetail = self.toDoItem.alertSelection;
    }
    else
        self.alertDetail = @"On current due date";
    
    if ([self.toDoItem.repeatSelection length] != 0){
        self.repeatDetail = self.toDoItem.repeatSelection;
    }
    
    self.hasNotification = NO;
    
    for(UILocalNotification *localN in [[UIApplication sharedApplication]scheduledLocalNotifications]){
        if([[localN.userInfo objectForKey:@"itemid"] isEqualToString:self.toDoItem.itemid]){
            NSLog(@"Has notification");
            self.hasNotification = YES;
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"MEMORY WARNING!!!");
}

#pragma mark - IBActions

-(IBAction)unWindFromAlert:(UIStoryboardSegue*) segue{
    //Retreive the source view controller and get the data from it
    AlertViewController *source = [segue sourceViewController];
    self.alertDetail = source.alertSelection;
    [self.reminderTableView reloadData];
}

-(IBAction)unWindFromRepeat:(UIStoryboardSegue*) segue{
    RepeatViewController *source = [segue sourceViewController];
    self.repeatDetail = source.repeatSelection;
    [self.reminderTableView reloadData];
}
- (IBAction)setButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"ReminderShortcutIdentifier" sender:self];
}


#pragma mark - Tableview setup

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.reminderTableViewArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier;

    if(indexPath.row == 0){
        cellIdentifier = @"AlertCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = [self.reminderTableViewArray objectAtIndex:indexPath.row];
        
        cell.detailTextLabel.text = self.alertDetail;
        
        return cell;
    }
    else if(indexPath.row == 1){
        cellIdentifier = @"RepeatCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (self.repeatDetail !=nil)
            cell.detailTextLabel.text = self.repeatDetail;
 
        return cell;
    }
    else{
        cellIdentifier = @"ReminderCell";
        [self.reminderTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.textLabel.text = @"Remind";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(self.mainSwitch == nil)
        {
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            [switchView addTarget:self action:@selector(switchControlHandling) forControlEvents:UIControlEventValueChanged];
            
            if(self.isInEditMode)
                [switchView setOn:self.hasNotification];
            else if(self.isShortcut)
                [switchView setOn:self.hasNotification];
            else
                [switchView setOn:YES];
            self.mainSwitch = switchView;
        }
        
        if([self.alertDetail isEqualToString:@"None"])
            [self.mainSwitch setOn:NO];
        else
            [self.mainSwitch setOn:YES];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Private functions

-(NSString*)getReminderDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    // get datepicker end value
    NSDate *choice = [self.reminderPicker date];
    NSString *endDate = [dateFormatter stringFromDate:choice];
    return endDate;
}

-(void)switchControlHandling{
    NSLog(@"Switch is %s", [self.mainSwitch isOn] ? "on" : "off" );
    
    if(self.isInEditMode)
    {
        if(![self.mainSwitch isOn])
        {
            self.alertDetail = @"None";
            [self.reminderTableView reloadData];
        }
        else{
            
            if(![self.toDoItem.alertSelection isEqualToString:@"None"] && [self.toDoItem.alertSelection length] !=0)
            {
                self.alertDetail = self.toDoItem.alertSelection;
                [self.reminderTableView reloadData];
            }
            else
            {
                self.alertDetail = @"On current due date";
                [self.reminderTableView reloadData];
            }
        }
    }
    else
    {
        if(![self.mainSwitch isOn])
        {
            self.alertDetail = @"None";
            [self.reminderTableView reloadData];
        }
        else{
            self.alertDetail = @"On current due date";
            [self.reminderTableView reloadData];
        }
    }
    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:@"AlertSegue"]) {
        AlertViewController *alertViewControllers = segue.destinationViewController;
        alertViewControllers.alertSelection = self.alertDetail;
    }
    
    else if ([segue.identifier isEqualToString:@"RepeatSegue"]) {
        RepeatViewController *repeatViewControllers = segue.destinationViewController;
        repeatViewControllers.repeatSelection = self.repeatDetail;
    }
}


@end
