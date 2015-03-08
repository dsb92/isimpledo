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
#import "Utility.h"
#import "DateWrapper.h"

@interface ToDoListTableViewController (){
    NSArray *_sections;
    NSMutableArray *_testArray;
}
@property (weak, nonatomic) IBOutlet UILabel *progressText;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL useCustomCells;
@property (nonatomic, weak) UIRefreshControl *refreshControl;

// Is private and thats why it's not declared in .h file
@property NSInteger indexPath;
@property NSNumber *selectedSegment;

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

-(NSDate*) updateAlertDate:(ToDoItem*)item{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSDate *reminderDate = [dateFormatter dateFromString:item.endDate];

            
            if(item.repeatSelection == nil || [item.repeatSelection isEqualToString:@"Never"]) return reminderDate;
            
            NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
            
            switch([self getRepeat:item]){
                case NSCalendarUnitDay:
                    [dateComponents setDay:1];
                    break;
                
                case NSCalendarUnitWeekday:
                    [dateComponents setDay:7];
                    break;
                
                case NSCalendarUnitMonth:
                    [dateComponents setMonth:1];
                    break;
                
                case NSCalendarUnitYear:
                    [dateComponents setYear:1];
                    break;
                
                default:
                    [dateComponents setDay:0];
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
        if([[localN.userInfo objectForKey:@"itemid"] isEqualToString:item.itemid]){
            [[UIApplication sharedApplication] cancelLocalNotification:localN];
            NSLog(@"Notification canceled");
            return;
        }
    }
}

// In order to edit a local notification u need to cancel it/delete it and then make a new one (unfortunately)
-(void) editLocalNotification:(ToDoItem*)item{
    
    // Cancel
    [self cancelLocalNotification:item];
    
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
    NSUInteger nextBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count] + 1;
    localNotification.applicationIconBadgeNumber = nextBadgeNumber;
    
    if(![item.repeatSelection isEqualToString:@"Never"])
        localNotification.repeatInterval = [self getRepeat:item];
    
    // Use a dictionary to keep track on each notification attacted to each to-do item.
    NSDictionary *info = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", item.itemid] forKey:@"itemid"];
    localNotification.userInfo = info;
    NSLog(@"Notification userInfo gets item id : %@",[info objectForKey:@"itemid"]);
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound
                                                                                                              categories:nil]];
    }
    
    NSLog(@"Notification created");
}

-(IBAction)unWindFromReminder:(UIStoryboardSegue*) segue{
    ReminderViewController *source = [segue sourceViewController];
    ToDoItem *item = source.toDoItem;
    
    if(source.isInEditMode){
        if (source.didCancel == NO){
            [self editLocalNotification:item];
            [self.tableView reloadData];
        }
        return;
    }
    
    if (item != nil){
        [self setLocalNotification:item];
        [self.toDoItems addObject:item];
        if(![self.selectedSegment isEqualToNumber:[NSNumber numberWithInt:0]])
            [self.tempItems addObject:item];

        [self.tableView reloadData];
    }
}

-(IBAction)unWindFromAdd:(UIStoryboardSegue*) segue{
    //Retreive the source view controller (AddToDoItemViewController) and get the data from it
    AddToDoItemViewController *source = [segue sourceViewController];
    ToDoItem *item = source.toDoItem;
    
    if(source.didCancel) return;
    
    if(source.isInEditMode){
        if (source.didCancel == NO){
            [self editLocalNotification:item];
            [self.tableView reloadData];
        }
        return;
    }
    
    if (item != nil && item.itemName != nil){
        NSString *segment = [NSString stringWithFormat:@"segment %@", self.selectedSegment];
        
        SegmentForToDoItem *segmentItem = [[SegmentForToDoItem alloc]init];
        segmentItem.thestringid = item.itemid;
        segmentItem.segment = segment;
        
        item.segmentForItem = segmentItem;
        
        [self.toDoItems addObject:item];
        if(![self.selectedSegment isEqualToNumber:[NSNumber numberWithInt:0]])
            [self.tempItems addObject:item];
        
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
    
    self.toDoItems = self.tempItems;
    
    NSMutableArray *mainArray = [[NSMutableArray alloc]init];
    for (int i = 0; i<[self.toDoItems count]; i++)
    {
        ToDoItem *item = [self.toDoItems objectAtIndex:i];
        NSArray *array = [[NSArray alloc]initWithObjects:item.itemid, item.itemName, [NSNumber numberWithBool:item.completed], item.creationDate, item.segmentForItem.thestringid, item.segmentForItem.segment, item.endDate, item.alertSelection, item.repeatSelection, nil];
        [mainArray addObject:array];
    }
    
    [mainArray writeToFile:filePath atomically:YES];
    NSLog(@"%@", filePath);
    NSLog(@"%@", mainArray);
    
    // How many items have exceeded the current date(if any reminder given)
    NSUInteger count = 0;
    
    NSDate *currentDate = [DateWrapper convertToDate:[DateWrapper getCurrentDate]];
    
    for (ToDoItem *item in self.toDoItems) {
        if(!item.completed && (item.alertSelection != nil || ![item.alertSelection isEqualToString:@"None"])){
            NSDate *itemDueDate = [DateWrapper convertToDate:item.endDate];
            if(itemDueDate==nil)continue;
            
            if([currentDate compare:itemDueDate] == NSOrderedDescending || [currentDate compare:itemDueDate] == NSOrderedSame){
                count++;
            }
        }
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
    
    // The following code renumbers the badges of pending notifications (in case user deletes or changes some local notifications while the app was running). So the following code runs, when the user
    // gets out of the app.
    
    // clear the badge on the icon
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // first get a copy of all pending notifications (unfortunately you cannot 'modify' a pending notification)
    NSArray *pendingNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    // if there are any pending notifications -> adjust their badge number
    if (pendingNotifications.count != 0)
    {
        // clear all pending notifications
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        // the for loop will 'restore' the pending notifications, but with corrected badge numbers
        // note : a more advanced method could 'sort' the notifications first !!!
        NSUInteger badgeNbr = 1;
        
        // LIFO order, the last notification created is the first that gets updated.
        for (UILocalNotification *notification in pendingNotifications)
        {
            // modify the badgeNumber
            NSLog(@"%@", notification);
            notification.applicationIconBadgeNumber = badgeNbr+count;
            badgeNbr++;
            
            // schedule 'again'
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification{
    [self.tableView reloadData];
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
        item.segmentForItem = [[SegmentForToDoItem alloc]init];
        NSArray *array = [mainArray objectAtIndex:i];
        
        @try {
            
            // get item id
            if ([array objectAtIndex:0]!=nil) {
                
                item.itemid = [array objectAtIndex:0];
            }
            
            // get item name
            if ([array objectAtIndex:1]!=nil) {
                
                item.itemName = [array objectAtIndex:1];
            }
            
            // get complete state
            if ([array objectAtIndex:2]!=nil) {
                // To retreive BOOL value from NSNumber object in array, add boolValue
                item.completed = [[array objectAtIndex:2]boolValue];
            }
            
            // get creation date
            if ([array objectAtIndex:3]!=nil) {
                item.creationDate = [array objectAtIndex:3];
            }
            
            // get segment string id for to-do item
            if ([array objectAtIndex:4]!=nil) {
                item.segmentForItem.thestringid = [array objectAtIndex:4];
            }
            
            // get segment segment for to-do item
            if ([array objectAtIndex:5]!=nil) {
                item.segmentForItem.segment = [array objectAtIndex:5];
            }
            
            // get end date
            if ([array objectAtIndex:6]!=nil) {
                item.endDate = [array objectAtIndex:6];
            }
            
            // get alert selection
            if ([array objectAtIndex:7]!=nil) {
                item.alertSelection = [array objectAtIndex:7];
            }
            
            // get repeat selection
            if ([array objectAtIndex:8]!=nil) {
                item.repeatSelection = [array objectAtIndex:8];
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
    
    if(currentProgress!=currentProgress)
        currentProgress=0.0;

    
    [self.progressBar setProgress:currentProgress animated:YES];
    [self.progressBar setNeedsDisplay];
    NSString *progressText = [NSString stringWithFormat:@"%1.0f/%1.0f completed tasks", completed, tasks];
    [self.progressText setText:progressText];
}

- (void) printDoToItems{
    for(ToDoItem *item in self.toDoItems){
        NSLog(@"Itemid: %@\nItemname: %@\nCreation date: %@\nDue date: %@\nAlert: %@\nRepeat: %@\nSegment string id: %@\nSegment segment: %@\n", item.itemid, item.itemName, item.creationDate, item.endDate, item.alertSelection, item.repeatSelection, item.segmentForItem.thestringid, item.segmentForItem.segment);
        
        NSLog(@"Completed: %s", item.completed ? "YES" : "NO");
        
        NSLog(@"\n");
    }
    
    NSLog(@"Local notifications:\n");
    
    for(UILocalNotification *localN in [[UIApplication sharedApplication]scheduledLocalNotifications])
    {
        /*
        //!!!OBS OBS REMEBER TO COMMENT THIS WHEN NOT TESTING!!!
         [[UIApplication sharedApplication]cancelAllLocalNotifications];
        */
        NSLog(@"%@", localN);
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup refresh control for example app
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(toggleCells:) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    [self.tableView addSubview:refreshControl];
    
    self.useCustomCells = NO;
    
    // If you set the seperator inset on iOS 6 you get a NSInvalidArgumentException...weird
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0); // Makes the horizontal row seperator stretch the entire length of the table view
    }
    
    self.toDoItems = [[NSMutableArray alloc]init];
    self.tempItems = self.toDoItems;
    
    self.selectedSegment = [NSNumber numberWithInt:0];
    [self loadInitialData];
    [self setProgressBar];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self printDoToItems];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    //Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.leftBarButtonItem = self.editButtonItem;
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
    
    if (toDoItem.endDate != nil && ![toDoItem.endDate isEqualToString:toDoItem.creationDate]){
        cell.detailTextLabel.text = [DateWrapper wrapDate:toDoItem.endDate];
    }
    else
        cell.detailTextLabel.text = @"";
    
    if(toDoItem.completed)
        cell.accessoryType = UITableViewCellAccessoryNone;
    else
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

    ToDoItem *item = [self.toDoItems objectAtIndex:indexPath.row];
    if(item.completed || self.editing) return;
    
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
        
        [leftUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
                                                    icon:[UIImage imageNamed:@"clock.png"]];
    }
    
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
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    switch (index) {
        case 0:{
            NSLog(@"left button 0 was pressed");
            NSLog(@"Index path: %ld", (long)cellIndexPath.row);
            ToDoItem *tappedItem = [self.toDoItems objectAtIndex:cellIndexPath.row];
            tappedItem.completed = !tappedItem.completed;
            if (tappedItem.completed && (tappedItem.repeatSelection == nil || [tappedItem.repeatSelection isEqualToString:@"Never"])) {
                [self cancelLocalNotification:tappedItem];
                tappedItem.endDate = nil;
                tappedItem.alertSelection = nil;
                tappedItem.repeatSelection = nil;
            }
            else if(tappedItem.completed && (tappedItem.repeatSelection != nil || ![tappedItem.repeatSelection isEqualToString:@"Never"])){
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
                [self cancelLocalNotification:tappedItem];
                
                ToDoItem *repeatItem = [[ToDoItem alloc]init];
                repeatItem.itemid = [Utility generateUniqID];
                repeatItem.itemName = tappedItem.itemName;
                repeatItem.creationDate = [dateFormatter stringFromDate:[NSDate date]];
                repeatItem.alertSelection = tappedItem.alertSelection;
                repeatItem.repeatSelection = tappedItem.repeatSelection;
                repeatItem.endDate = [dateFormatter stringFromDate:[self updateAlertDate:tappedItem]];
                repeatItem.completed = NO;
 
                tappedItem.alertSelection = nil;
                tappedItem.repeatSelection = nil;
                tappedItem.endDate = nil;
                
                [self setLocalNotification:repeatItem];
                [self.toDoItems addObject:repeatItem];
                [self.tempItems addObject:repeatItem];
            }
            
            [cell hideUtilityButtonsAnimated:NO];
            [self.tableView reloadData];
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
        
        NSDate *currentDate = [DateWrapper convertToDate:[DateWrapper getCurrentDate]];
        NSDate *itemDueDate = [DateWrapper convertToDate:item.endDate];
        
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        
        if(itemDueDate==nil)return;
        // If current date is greater than item's due date
        if([currentDate compare:itemDueDate] == NSOrderedDescending || [currentDate compare:itemDueDate] == NSOrderedSame)
        {
            cell.textLabel.textColor = [UIColor redColor];
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
        else{
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.textColor = [UIColor blackColor];
        }
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
        [self.tempItems removeObject:item];
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
        reminderViewController.isInEditMode = YES;
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
    reminderViewController.isInEditMode = NO;
    reminderViewController.isShortcut = NO;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


-(IBAction)editButton:(id)sender{
    self.editing = !self.editing;
    [self.tableView setEditing:self.editing animated:YES];
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

-(NSMutableArray*)sortedItemsOnDate:(NSMutableArray*)items{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"endDate"
                                                 ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [items sortedArrayUsingDescriptors:sortDescriptors];
    return [NSMutableArray arrayWithArray:sortedArray];
}

-(void)groupItems:(NSInteger)comDay segment:(NSString*)segment{
    for (ToDoItem *item in self.tempItems) {
        NSDate *itemdate = [DateWrapper convertToDate:item.endDate];
        
        if(itemdate==nil)
        {
            if([item.itemid isEqualToString:item.segmentForItem.thestringid] && [item.segmentForItem.segment isEqualToString:segment])
                [self.sortedItems addObject:item];
        }
        else{
            NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute | NSCalendarUnitHour
                                          | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:itemdate];
            
            NSDateComponents *components = [[NSDateComponents alloc]init];
            
            [components setDay:comDay];
            
            NSDate *tomorrow = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0];
            
            NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute | NSCalendarUnitHour
                                       | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:tomorrow];
            
            if(comDay == 2)
            {
                if([today day] <= [otherDay day] &&
                   [today month] <= [otherDay month] &&
                   [today year] <= [otherDay year]){
                    //do stuff
                    [self.sortedItems addObject:item];
                }
            }else{
                if([today day] == [otherDay day] &&
                   [today month] == [otherDay month] &&
                   [today year] == [otherDay year]){
                    //do stuff
                    [self.sortedItems addObject:item];
                }
            }
            
        }
    }
    
    self.toDoItems = [self sortedItemsOnDate:self.sortedItems];
    [self.tableView reloadData];
}

-(IBAction)mainControlSwitched:(id)sender{
    self.sortedItems = [[NSMutableArray alloc]init];
    self.selectedSegment = [NSNumber numberWithInteger:[sender selectedSegmentIndex]];

    // All
    if([sender selectedSegmentIndex]==0){
        self.tempItems = [self sortedItemsOnDate:self.tempItems];
        self.toDoItems = self.tempItems;
        [self.tableView reloadData];
    }
    
    // Today
    else if([sender selectedSegmentIndex]==1){
        [self groupItems:0 segment:@"segment 1"];
    }
    
    // Tomorrow
    else if([sender selectedSegmentIndex]==2){
        [self groupItems:1 segment:@"segment 2"];
    }
    
    // Future
    else if([sender selectedSegmentIndex]==3){
        [self groupItems:2 segment:@"segment 3"];
    }
}

@end
