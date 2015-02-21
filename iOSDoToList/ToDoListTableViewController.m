//
//  ToDoListTableViewController.m
//  iOSDoToList
//
//  Created by David Buhauer on 17/01/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "SWTableViewCell.h"
#import "UMTableViewCell.h"
#import "ToDoListTableViewController.h"
#import "AddToDoItemViewController.h"
#import "ReminderViewController.h"
#import "ToDoItem.h"

@interface ToDoListTableViewController (){
    NSArray *_sections;
    NSMutableArray *_testArray;
}
@property (weak, nonatomic) IBOutlet UILabel *progressText;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (nonatomic) BOOL useCustomCells;
@property (nonatomic, weak) UIRefreshControl *refreshControl;

// Is private and thats why it's not declared in .h file.

@property NSInteger indexPath;

@end

@implementation ToDoListTableViewController

-(NSDate*) getAlertDate: (ToDoItem*) item{
    NSString *alertSelection = item.alertSelection;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSDate *reminderDate = [dateFormatter dateFromString:item.endDate];
    //NSDateComponents *calComponents = [[NSCalendar currentCalendar] components: NSCalendarUnitMinute | NSCalendarUnitHour| NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
    
    if([alertSelection isEqualToString:@"5 minutes before"]){
        [dateComponents setMinute:-5];
    }
    
    else if([alertSelection isEqualToString:@"15 minuttes before"]){
        [dateComponents setMinute:-15];
    }
    
    else if([alertSelection isEqualToString:@"30 minutes before"]){
        [dateComponents setMinute:-30];
    }
    
    else if([alertSelection isEqualToString:@"1 hour before"]){
        [dateComponents setHour:-1];
    }
    
    else if([alertSelection isEqualToString:@"2 hours before"]){
        [dateComponents setHour:-2];
    }
    
    else if([alertSelection isEqualToString:@"1 day before"]){
        [dateComponents setDay:-1];
    }
    
    else if([alertSelection isEqualToString:@"2 days before"]){
        [dateComponents setDay:-2];
    }
    
    else if([alertSelection isEqualToString:@"1 week before"]){
        [dateComponents setDay:-7];
    }
    
    else{
        // Return alert on current due date.
        return reminderDate;
    }
    
    NSDate *alert = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:reminderDate options:0];
    return alert;
}

-(NSCalendarUnit) getRepeat:(ToDoItem*) item{
    if([item.repeatSelection isEqualToString:@"Every day"])
        return NSCalendarUnitDay;
    
    else if([item.repeatSelection isEqualToString:@"Every week"])
        return NSCalendarUnitWeekday;
    
    
    else if([item.repeatSelection isEqualToString:@"Every month"])
        return NSCalendarUnitMonth;
    
    else if([item.repeatSelection isEqualToString:@"Every year"])
        return NSCalendarUnitYear;
    
    else
        return 0;
}

-(void) cancelLocalNotification:(ToDoItem*)item{
    for(UILocalNotification *localN in [[UIApplication sharedApplication]scheduledLocalNotifications]){
        if([[localN.userInfo objectForKey:@"name"] isEqualToString:item.itemName]){
            [[UIApplication sharedApplication] cancelLocalNotification:localN];
            return;
        }
    }
}

// In order to edit a local notification u need to cancel it/delete it and then make a new one (unfortunately)
-(void) editLocalNotification:(ToDoItem*)item{
    
    // Cancel
    [self cancelLocalNotification:item];
    NSLog(@"Notification canceled");
    
    // Create a new
    [self setLocalNotification:item];
}

-(void) setLocalNotification:(ToDoItem*) item{
    if(item.alertSelection == nil || [item.alertSelection isEqualToString:@"None"]) return;
    
    // Schedule the notification
    UILocalNotification *localNotification = [[UILocalNotification alloc]init];
    localNotification.fireDate = [self getAlertDate:item];
    localNotification.alertBody = item.itemName;
    localNotification.alertAction = @"Show me the item";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.timeZone = [NSTimeZone localTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber]+1;
    
    if(![item.repeatSelection isEqualToString:@"Never"])
        localNotification.repeatInterval = [self getRepeat:item];
    
    // Use a dictionary to keep track on each notification attacted to each to-do item.
    NSDictionary *info = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", item.itemName] forKey:@"name"];
    localNotification.userInfo = info;
    NSLog(@"Notification userInfo gets item name : %@",[info objectForKey:@"name"]);
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound
                                                                                                              categories:nil]];
    }
    
    NSLog(@"Notification created");
}

-(IBAction)unWindFromAdd:(UIStoryboardSegue*) segue{
    //Retreive the source view controller (AddToDoItemViewController) and get the data from it
    AddToDoItemViewController *source = [segue sourceViewController];
    ToDoItem *item = source.toDoItem;
    
    if(source.isInEditMode){
        if (source.didCancel == NO){
            [self editLocalNotification:item];
            [self.tableView reloadData];
        }
        return;
    }
  
    if (item != nil && item.itemName != nil){
        [self setLocalNotification:item];
        [self.toDoItems addObject:item];
        [self.tableView reloadData];
    }
}

-(IBAction)unWindFromShortCut:(UIStoryboardSegue*) segue{
    ReminderViewController *source = [segue sourceViewController];
    
    if(source.didCancel == NO){
        [self editLocalNotification:source.toDoItem];
    }
    [self.tableView reloadData];
}

-(NSString *)pathOfFile{
    // Returns an array of directories
    // App's document is the first element in this array
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path =[[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"todolist.plist"]];
    
    return path;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification{
    NSString *filePath= [self pathOfFile];
    
    NSMutableArray *mainArray = [[NSMutableArray alloc]init];
    for (int i = 0; i<[self.toDoItems count]; i++)
    {
        ToDoItem *item = [self.toDoItems objectAtIndex:i];
        NSArray *array = [[NSArray alloc]initWithObjects:item.priority, item.itemName, [NSNumber numberWithBool:item.completed], item.creationDate, item.endDate, item.alertSelection, item.repeatSelection, nil];
        [mainArray addObject:array];
    }
    
    [mainArray writeToFile:filePath atomically:YES];
    NSLog(@"%@", filePath);
    NSLog(@"%@", mainArray);
}

-(void)loadInitialData{
    /*
    ToDoItem *item1 = [[ToDoItem alloc]init];
    item1.itemName = @"Buy milk";
    [self.toDoItems addObject:item1];
    
    ToDoItem *item2 = [[ToDoItem alloc]init];
    item2.itemName = @"Buy eggs";
    [self.toDoItems addObject:item2];
    
    ToDoItem *item3 = [[ToDoItem alloc]init];
    item3.itemName = @"Read a book";
    [self.toDoItems addObject:item3];
     */
    NSString *filePath= [self pathOfFile];

    NSMutableArray *mainArray = [NSMutableArray arrayWithContentsOfFile:filePath];
    
    for (int i=0; i<[mainArray count]; i++) {
        ToDoItem *item = [[ToDoItem alloc]init];
        NSArray *array = [mainArray objectAtIndex:i];
        
        // get priority
        item.priority = [array objectAtIndex:0];
        
        @try {
            
            // get item name
            if ([array objectAtIndex:1]!=nil) {
                // To retreive BOOL value from NSNumber object in array, add boolValue
                item.itemName = [array objectAtIndex:1];
            }
            
            // get complete state
            if ([array objectAtIndex:2]!=nil) {
                item.completed = [[array objectAtIndex:2]boolValue];
            }
            
            // get creation date
            if ([array objectAtIndex:3]!=nil) {
                item.creationDate = [array objectAtIndex:3];
            }
            
            // get end date
            if ([array objectAtIndex:4]!=nil) {
                item.endDate = [array objectAtIndex:4];
            }
            
            // get alert selection
            if ([array objectAtIndex:5]!=nil) {
                item.alertSelection = [array objectAtIndex:5];
            }
            
            // get repeat selection
            if ([array objectAtIndex:6]!=nil) {
                item.repeatSelection = [array objectAtIndex:6];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }

        [self.toDoItems addObject:item];
    }
}

- (void) setProgressBar{
    float tasks = [self.toDoItems count];
    float completed = 0.0;
    float currentProgress = 0.0;
    
    
    for (ToDoItem *item in self.toDoItems) {
        if (item.completed) {
            completed++;
        }
    }
    
    @try {
        currentProgress = completed/tasks;
    }
    @catch (NSException *exception) {
        NSLog(@"0 out 0 tasks completed: %@", [NSThread callStackSymbols]);
    }

    
    [self.progressBar setProgress:currentProgress animated:YES];
    [self.progressBar setNeedsDisplay];
    NSString *progressText = [NSString stringWithFormat:@"%1.0f/%1.0f completed tasks", completed, tasks];
    [self.progressText setText:progressText];
}

- (void) printDoToItems{
    for(ToDoItem *item in self.toDoItems){
        NSLog(@"Item: %@\nPriority: %@\nCreation date: %@\nDue date: %@\nCompleted: %@\nAlert: %@\nRepeat: %@\n", item.itemName, item.priority, item.creationDate, item.endDate, item.completed, item.alertSelection, item.repeatSelection);
        
        NSLog(@"\n");
    }
    
    NSLog(@"Local notifications:\n");
    
    for(UILocalNotification *localN in [[UIApplication sharedApplication]scheduledLocalNotifications])
    {
        [[UIApplication sharedApplication]cancelAllLocalNotifications];
        NSLog(@"%@", localN.userInfo);
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup refresh control for example app
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(toggleCells:) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    self.useCustomCells = NO;
    
    // If you set the seperator inset on iOS 6 you get a NSInvalidArgumentException...weird
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0); // Makes the horizontal row seperator stretch the entire length of the table view
    }
    
    self.toDoItems = [[NSMutableArray alloc]init];
    [self loadInitialData];
    [self setProgressBar];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self printDoToItems];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    [self setProgressBar];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.toDoItems count];
}

#pragma mark - UIRefreshControl Selector

- (void)toggleCells:(UIRefreshControl*)refreshControl
{
    [refreshControl beginRefreshing];
    /*
    self.useCustomCells = !self.useCustomCells;
    if (self.useCustomCells)
    {
        self.refreshControl.tintColor = [UIColor yellowColor];
    }
    else
    {
        self.refreshControl.tintColor = [UIColor blueColor];
    }
     */
    [self.tableView reloadData];
    [refreshControl endRefreshing];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    static NSString *cellIdentifier = @"ListPrototypeCell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.leftUtilityButtons = [self leftButtons:indexPath];
    //cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    ToDoItem *toDoItem = [self.toDoItems objectAtIndex:indexPath.row];
    
    cell.textLabel.text = toDoItem.itemName;
    
    NSString *priority = [[NSString alloc]initWithFormat:@"Priority: %@\t\t ", toDoItem.priority];
    NSString *dueDate = [[NSString alloc]initWithFormat:@"Due date: %@", toDoItem.endDate];
    
    if (toDoItem.endDate != nil && ![toDoItem.endDate isEqualToString:toDoItem.creationDate]){
        cell.detailTextLabel.text = [priority stringByAppendingString:dueDate];
    }
    else
        cell.detailTextLabel.text = priority;
    
    /*
    if (toDoItem.completed) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
     */
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
     if ([self.expandedCells containsObject:indexPath]){
     [self.expandedCells removeObject:indexPath];
     }
     else{
     [self.expandedCells addObject:indexPath];
     }
     [tableView beginUpdates];
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
     cell.detailTextLabel.text = @"TEST";
     cell.detailTextLabel.hidden = NO;
     [tableView endUpdates];
     */

    if(self.editing)
        return;
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    // Bug in SWTableViewCell API when using selectedRowAtIndexPath, so save this indexPath to NSInteger variable.
    self.indexPath = indexPath.row;
    
    // Manually performSegue since using SWTableViewCell API does not work with it, when cell tapped.
    [self performSegueWithIdentifier:@"EditToDoItem" sender:self];
}


- (NSArray *)rightButtons
{
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    /*
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"More"];
    */
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}


// Take a cell as parameter
- (NSArray *)leftButtons: (NSIndexPath*)indexPath
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    NSIndexPath *cellIndexPath = indexPath;
    ToDoItem *tappedItem = [self.toDoItems objectAtIndex:cellIndexPath.row];
    
    if (tappedItem.completed) {
        [leftUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
                                                    icon:[UIImage imageNamed:@"cross.png"]];
    }
    else{
        [leftUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
                                                    icon:[UIImage imageNamed:@"check.png"]];
    }
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
                                                icon:[UIImage imageNamed:@"clock.png"]];
    /*
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
                                                icon:[UIImage imageNamed:@"list.png"]];
     */
    
    return leftUtilityButtons;
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:{
            NSLog(@"left button 0 was pressed");
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            NSLog(@"Index path: %ld", (long)cellIndexPath.row);
            ToDoItem *tappedItem = [self.toDoItems objectAtIndex:cellIndexPath.row];
            tappedItem.completed = !tappedItem.completed;
            [self.tableView reloadData];
            [cell hideUtilityButtonsAnimated:YES];
        }
            break;
        case 1:{
            NSLog(@"Code to open ReminderViewController passed with to do item object.");
            // Code for Reminder functionalicty.
            
            //ReminderViewController *reminderController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReminderController"];
            //reminderController.cancelButton = [[UIBarButtonItem alloc]init];
            //[reminderController.cancelButton setTarget:self];
            //[reminderController.cancelButton setAction:@selector(unWindFromReminder:)];
            //[self.navigationController pushViewController:reminderController animated:YES];
            
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            self.indexPath = cellIndexPath.row;
            [self performSegueWithIdentifier:@"ReminderShortcutIdentifier" sender:self];
        }
            break;
        case 2:
            NSLog(@"left button 2 was pressed");
            break;
        case 3:
            NSLog(@"left btton 3 was pressed");
        default:
            break;
    }
}

/*
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            [self.toDoItems removeObjectAtIndex:cellIndexPath.row];
            // Delete the row from the data source
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case 1:
        {
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        default:
            break;
    }
}
 */


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set background color of cell here if you don't want default white
    ToDoItem *item = [self.toDoItems objectAtIndex:indexPath.row];
    
    if(item.completed){
        cell.backgroundColor = [UIColor lightGrayColor];
        NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:item.itemName attributes:attributes];
        
        cell.textLabel.attributedText = attributedString;
    }
    else{
        cell.backgroundColor = [UIColor whiteColor];
        NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleNone]};
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:item.itemName attributes:attributes];
        cell.textLabel.attributedText = attributedString;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ToDoItem *item = [self.toDoItems objectAtIndex:indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.toDoItems removeObjectAtIndex:indexPath.row];
        
        // Delete local notifications if any
        [self cancelLocalNotification:item];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    ToDoItem *item = [self.toDoItems objectAtIndex:fromIndexPath.row];
    [self.toDoItems removeObjectAtIndex:fromIndexPath.row];
    [self.toDoItems insertObject:item atIndex:toIndexPath.row];
    
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    /*
    if ([identifier isEqualToString:@"EditToDoItem"]) {
        
        //Put your validation code here and return YES or NO as needed
        if (self.editing) {
            NSLog(@"Segue not Blocked - Edit mode on");
            return YES;
        }
        
        NSLog(@"Segue Blocked - Edit mode is not on");
        return NO;
    }
     */
    
    return YES;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    /*
    if ([segue.identifier isEqualToString:@"EditToDoItem"]) {
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        EditToDoItemViewController *editToDoItemVIewController = [navController topViewController];
        editToDoItemVIewController.toDoItem = [self.toDoItems objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    }
     */
    
    UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
    
    AddToDoItemViewController *addToDoItemVIewController;
    ReminderViewController *reminderViewController;
    ToDoItem *item;

    if ([segue.identifier isEqualToString:@"EditToDoItem"]) {
        item = [self.toDoItems objectAtIndex:self.indexPath];
        addToDoItemVIewController = (AddToDoItemViewController*)[navController topViewController];
        addToDoItemVIewController.title = @"Edit To-Do item";
        addToDoItemVIewController.isInEditMode = YES;
        addToDoItemVIewController.toDoItem = item;
        return;
    }
    else if ([segue.identifier isEqualToString:@"ReminderShortcutIdentifier"]){
        item = [self.toDoItems objectAtIndex:self.indexPath];
        reminderViewController = (ReminderViewController*)navController;
        reminderViewController.toDoItem = item;
        reminderViewController.isShortcut = YES;
        return;
    }
    
    addToDoItemVIewController.isInEditMode = NO;
    reminderViewController.isShortcut = NO;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}


-(IBAction)editButton:(id)sender{
    self.editing = !self.editing;
    UIBarButtonItem *barButtonItem;
    if (self.editing){
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButton:)];
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else{
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButton:)];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
}

@end
