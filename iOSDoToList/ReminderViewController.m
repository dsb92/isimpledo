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

@interface ReminderViewController () 
@property (weak, nonatomic) IBOutlet UIDatePicker *reminderPicker;
@property (weak, nonatomic) IBOutlet UILabel *reminderDateLabel;
@property (strong, nonatomic) IBOutlet UITableView *reminderTableView;

@end

@implementation ReminderViewController


-(IBAction)rightButtonAction:(id)sender;{
    
    //UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
    
    if (!self.isShortcut) {
        //[self performSegueWithIdentifier:@"AddToItemSegueIdentifier" sender:sender];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self performSegueWithIdentifier:@"ToDoListTableViewSegueIdentifier" sender:sender];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.reminderTableViewArray = [[NSArray alloc]initWithObjects:@"Alert", @"Repeat", nil];
    
    [self.reminderPicker setMinimumDate:[NSDate date]];
    
    if([self.toDoItem.endDate length] == 0 )
        self.reminderDateLabel.text = self.getReminderDate;
    else {
        self.reminderDateLabel.text = self.toDoItem.endDate;
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
    
    if ([self.toDoItem.repeatSelection length] != 0){
        self.repeatDetail = self.toDoItem.repeatSelection;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"MEMORY WARNING!!!");
}


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

-(IBAction)reminderDateChanged:(id)sender{
    self.reminderDateLabel.text = self.getReminderDate;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.reminderTableViewArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier;

    if(indexPath.row == 0){
        cellIdentifier = @"AlertCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = [self.reminderTableViewArray objectAtIndex:indexPath.row];
        if (self.alertDetail != nil)
            cell.detailTextLabel.text = self.alertDetail;
        
        return cell;
    }
    else{
        cellIdentifier = @"RepeatCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (self.repeatDetail != nil)
            cell.detailTextLabel.text = self.repeatDetail;
        
        return cell;
    }
    
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}
 */

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
    
    if (sender != self.setButton)
    {
        self.didCancel = YES;
        return;
    }
    
    self.didCancel = NO;
    
    self.toDoItem.endDate = self.reminderDateLabel.text;
    self.toDoItem.alertSelection = self.alertDetail;
    self.toDoItem.repeatSelection = self.repeatDetail;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    // get datepicker end value
    NSDate *choice = [self.reminderPicker date];
    NSString *endDate = [dateFormatter stringFromDate:choice];
    self.toDoItem.endDate = endDate;
}


@end
