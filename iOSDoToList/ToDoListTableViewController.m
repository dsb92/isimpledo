//
//  ToDoListTableViewController.m
//  iOSDoToList
//
//  Created by David Buhauer on 17/01/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "SWTableViewCell.h"
#import "ToDoListTableViewController.h"
#import "AddToDoItemViewController.h"
#import "ReminderViewController.h"
#import "ToDoItem.h"
#import "Utility.h"
#import "DateWrapper.h"
#import "LocalNotifications.h"
#import "CustomListManager.h"
#import "ParseCloud.h"

@interface ToDoListTableViewController (){
    NSArray *_sections;
    NSMutableArray *_testArray;
}
@property (weak, nonatomic) IBOutlet UILabel *progressText;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButton;
@property (weak, nonatomic) IBOutlet UIToolbar *myToolbar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *selectAllButton;
@property (nonatomic, weak) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addUIBarButtonItem;

// Is private and thats why it's not declared in .h file
@property NSInteger indexPath;
@property NSNumber *selectedSegment;
@property BOOL hasSelectedAllInEdit;
@property CustomListManager *sharedManager;

@end

@implementation ToDoListTableViewController

#pragma mark - didLoad

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"ToDoListTableViewController View did load");
    
    self.sharedManager = [CustomListManager sharedManager];
    
    // Setup refresh control for example app
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(toggleCells:) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    [self.tableView addSubview:refreshControl];
    
    if (self.toDoItems == nil)
        self.toDoItems = [[NSMutableArray alloc]init];
    
    if (self.tempItems == nil)
        self.tempItems = [[NSMutableArray alloc]init];
    
    self.selectedSegment = [NSNumber numberWithInt:0];
    
    self.toDoItems = [self sortedItemsOnDate:self.toDoItems];
    
    [self.tableView reloadData];
    
    for(ToDoItem *item in self.toDoItems)
        [self.tempItems addObject:item];
    
    [self setProgressBar];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self printDoToItems];
    
    [self handleEditButton];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    //Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// User presses back button ("lists") from navigationcontroller
- (void)viewWillDisappear:(BOOL)animated{   
    [super viewWillDisappear:animated];
    
    NSLog(@"view vill disappear gone...");
    
}

#pragma mark - applicationDidEnterBackGround

- (void)applicationDidEnterBackground:(NSNotification *)notification{
    
    [ToDoItem saveToLocal];
    
}

-(NSString *)pathOfFile{
    // Returns an array of directories
    // App's document is the first element in this array
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path =[[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"todolist.plist"]];
    
    return path;
}

-(void)saveToLocal{
    
    NSString *filePath= [self pathOfFile];
    
    NSArray * sortedKeys = [[self.sharedManager.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    if (!self.isEverythingFilter && !self.isCompletedFilter)
        [self.sharedManager.customListDictionary setValue:self.tempItems forKey:[sortedKeys objectAtIndex:self.selectedListIndex]];
    
    NSMutableArray *listArray = [[NSMutableArray alloc]init];
    
    for(id key in sortedKeys){
        NSMutableArray *mainArray = [[NSMutableArray alloc]init];
        
        // Add key as first item (Grocery etc..)
        [mainArray addObject:key];
        // Return to do list for each key (Grocery, school, private etc.)
        id list = [self.sharedManager.customListDictionary objectForKey:key];
        
        for (ToDoItem *item in list) {
            NSMutableArray *array = [[NSMutableArray alloc]init];
            
            /* Non-nullable values */
            [array addObject:item.itemid];
            [array addObject:item.itemName];
            [array addObject:[NSNumber numberWithBool:item.completed]];
            [array addObject:item.creationDate];
            [array addObject:item.listKey];
            
            /* Nullable values */
            if(item.segmentForItem.thestringid == nil)
                [array addObject:@""];
            else
                [array addObject:item.segmentForItem.thestringid];
            
            if(item.segmentForItem.segment == nil)
                [array addObject:@""];
            else
                [array addObject:item.segmentForItem.segment];
            
            if(item.endDate == nil)
                [array addObject:@""];
            else
                [array addObject:item.endDate];
            
            if(item.alertSelection== nil)
                [array addObject:@""];
            else
                [array addObject:item.alertSelection];
            
            if(item.repeatSelection == nil)
                [array addObject:@""];
            else
                [array addObject:item.repeatSelection];
            
            if(item.actualEndDate == nil)
                NSLog(@"%@ has nil actualEndDate!", item.itemName);
            else
                [array addObject:item.actualEndDate];
            
            [mainArray addObject:array];
        }
        
        [listArray addObject:mainArray];
    }
    
    // listarray{
    //              mainArray(grocery) {
    //                                  buy milk {
    //                                              itemid
    //                                              itemname
    //                                              ...
    //                                          }
    //                                  buy m  {
    //                                              itemid
    //                                              itemname
    //                                              ...
    //                                          }
    //                                  }
    //              mainArray(school)   {
    //                                   math {
    //                                              itemid
    //                                              itemname
    //                                              ...
    //                                          }
    //                                  english  {
    //                                              itemid
    //                                              itemname
    //                                              ...
    //                                          }
    //                                  }
    //          }
    
    [listArray writeToFile:filePath atomically:YES];
    
    if(![self.selectedSegment isEqualToNumber:[NSNumber numberWithInt:0]])
        [self segmentControlHandling];
    
}

#pragma mark - applicationDidBecomeActive

- (void)applicationDidBecomeActive:(NSNotification *)notification{
    // If user is in editmode, get out.
    if(self.editing)
        [self editButton:self];
    [self.tableView reloadData];
}

#pragma mark - Tableview setup

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    [self setProgressBar];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.toDoItems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    
    static NSString *cellIdentifier = @"ListPrototypeCell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    //SWTableViewCell *cell = [[SWTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    if (!self.isCompletedFilter){
        cell.leftUtilityButtons = [self leftButtons:indexPath];
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;
    }
    
    ToDoItem *toDoItem = [self.toDoItems objectAtIndex:indexPath.row];
    
    cell.textLabel.text = toDoItem.itemName;
    
    if (toDoItem.endDate != nil &&  ![toDoItem.endDate isEqualToString:toDoItem.creationDate]){
        NSString *detailText = [DateWrapper wrapDate:toDoItem.endDate];
        cell.detailTextLabel.text = detailText;
        // Redraw the cell immediately
        [cell layoutSubviews];
    }
    else
        cell.detailTextLabel.text = @"";
    
    if(toDoItem.completed)
        cell.accessoryType = UITableViewCellAccessoryNone;
    else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    UIImageView *repeatImage = (UIImageView*)[cell viewWithTag:100];
    if([toDoItem.repeatSelection length] !=0 && ![toDoItem.repeatSelection isEqualToString:@"Never"])
        repeatImage.hidden = NO;
    else
        repeatImage.hidden = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.editing)
        self.deleteBarButton.enabled = YES;
    
    ToDoItem *item = [self.toDoItems objectAtIndex:indexPath.row];
    if(item.completed || self.editing || self.isCompletedFilter) return;
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    // Bug in SWTableViewCell API when using selectedRowAtIndexPath, so save this indexPath to NSInteger variable.
    self.indexPath = indexPath.row;
    
    // Manually performSegue since using SWTableViewCell API does not work with it, when cell tapped.
    [self performSegueWithIdentifier:@"EditToDoItem" sender:self];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    if(selectedRows.count > 0)
        self.deleteBarButton.enabled = YES;
    else
        self.deleteBarButton.enabled = NO;
}


#pragma mark - SWTableView setup

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
        // Complete button
        case 0:{
            NSLog(@"left button 0 was pressed");
            NSLog(@"Index path: %ld", (long)cellIndexPath.row);
            ToDoItem *tappedItem = [self.toDoItems objectAtIndex:cellIndexPath.row];
            tappedItem.completed = !tappedItem.completed;
            // If repeat selection is not chosen
            if (tappedItem.completed && ([tappedItem.repeatSelection length]==0  || [tappedItem.repeatSelection isEqualToString:@"Never"])) {
                [LocalNotifications cancelLocalNotification:tappedItem];
                tappedItem.endDate = nil;
                //tappedItem.actualEndDate = nil;
                tappedItem.alertSelection = nil;
                tappedItem.repeatSelection = nil;
                
                [self updateCustomDictionary:tappedItem operation:@"edit"];
            }
            // If repeat selection is chosen update item with new notification.
            else if(tappedItem.completed && ([tappedItem.repeatSelection length]!=0 || ![tappedItem.repeatSelection isEqualToString:@"Never"])){
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                
                [LocalNotifications cancelLocalNotification:tappedItem];
                
                ToDoItem *repeatItem = [[ToDoItem alloc]init];
                repeatItem.itemid = [Utility generateUniqID];
                repeatItem.itemName = tappedItem.itemName;
                repeatItem.creationDate = [dateFormatter stringFromDate:[NSDate date]];
                repeatItem.alertSelection = tappedItem.alertSelection;
                repeatItem.repeatSelection = tappedItem.repeatSelection;
                NSDate *date = [ToDoItem updateAlertDate:tappedItem];
                repeatItem.endDate = [dateFormatter stringFromDate:date];
                repeatItem.actualEndDate = date;
                repeatItem.completed = NO;
                repeatItem.listKey = tappedItem.listKey;
                
                tappedItem.alertSelection = nil;
                tappedItem.repeatSelection = nil;
                tappedItem.endDate = nil;
                //tappedItem.actualEndDate = nil;
                
                [LocalNotifications setLocalNotification:repeatItem isOn:YES];
                [self.toDoItems addObject:repeatItem];
                [self.tempItems addObject:repeatItem];
                
                [self updateSegmentControl:repeatItem];
                
                // If Everything filter is chosen, update respektive item.
                [self updateCustomDictionary:tappedItem operation:@"edit"];
                [self updateCustomDictionary:repeatItem operation:@"add"];
            }

            [ToDoItem updateSegmentForItem:tappedItem segment:self.selectedSegment];
            
            [cell hideUtilityButtonsAnimated:NO];
            [self.tableView reloadData];
        }
            break;
        // Shortcut reminder button
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

 - (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
 {
 switch (index) {
 // Delete button
 case 0:
 {
     // Delete button was pressed
      NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
     
     ToDoItem *item = [self.toDoItems objectAtIndex:cellIndexPath.row];

     [self.toDoItems removeObjectAtIndex:cellIndexPath.row];
     [self.tempItems removeObject:item];
     // Delete local notifications if any
     [LocalNotifications cancelLocalNotification:item];
     
     [self updateCustomDictionary:item operation:@"remove"];
     
     // Delete the row from the data source
     [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
     [self handleEditButton];
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



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set background color of cell here if you don't want default white
    ToDoItem *item = [self.toDoItems objectAtIndex:indexPath.row];
    
    if(item.completed){
        cell.backgroundColor = [UIColor lightGrayColor];
        NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:item.itemName attributes:attributes];
        
        cell.textLabel.attributedText = attributedString;
        cell.textLabel.textColor = [UIColor blackColor];
        return;
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
            return;
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

// Disable default delete button.
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
    
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ToDoItem *item = [self.toDoItems objectAtIndex:indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.toDoItems removeObjectAtIndex:indexPath.row];
        [self.tempItems removeObject:item];
        // Delete local notifications if any
        [LocalNotifications cancelLocalNotification:item];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self handleEditButton];
        
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
        return leftUtilityButtons;
    }
    else{
        [leftUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
                                                    icon:[UIImage imageNamed:@"check.png"]];
        
        for(UILocalNotification *localN in [[UIApplication sharedApplication]scheduledLocalNotifications]){
            if([[localN.userInfo objectForKey:@"itemid"] isEqualToString:tappedItem.itemid]){
                [leftUtilityButtons sw_addUtilityButtonWithColor:
                 [UIColor colorWithRed:0.05f green:0.69f blue:1.0f alpha:1.0]
                                                            icon:[UIImage imageNamed:@"clock_alert.png"]];
                return leftUtilityButtons;
            }
        }
        
        [leftUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.05f green:0.69f blue:1.0f alpha:1.0]
                                                    icon:[UIImage imageNamed:@"clock.png"]];
        return leftUtilityButtons;
    }
    
    /*
     [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
     icon:[UIImage imageNamed:@"list.png"]];
     */
}


#pragma mark - IBActions

-(IBAction)mainControlSwitched:(id)sender{
    self.selectedSegment = [NSNumber numberWithInteger:[sender selectedSegmentIndex]];
    
    [self segmentControlHandling];
    
}


-(IBAction)unWindFromAdd:(UIStoryboardSegue*) segue{
    //Retreive the source view controller (AddToDoItemViewController) and get the data from it
    AddToDoItemViewController *source = (AddToDoItemViewController*)self.viewController;
    ToDoItem *item = source.toDoItem;
    self.toDoItem = item;
    self.selectedKey = source.selectedKey;
    
    if([[(UIBarButtonItem*)segue title]isEqualToString:@"Cancel"]){
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    // get to do item name from textfield
    if (source.textField.text.length > 0) {
        // Cancel any local notifaction attached to the old item name contained in dictionary.
        if(source.isInEditMode && [self.toDoItem.endDate length] != 0)
            [LocalNotifications cancelLocalNotification:self.toDoItem];
        self.toDoItem.itemName = source.textField.text;
        self.toDoItem.completed = false;
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    // Textfield is over 0 length, do stuff then.
    if (source.dueDateLabel.text.length == 0){
        self.toDoItem.endDate = nil;
        self.toDoItem.alertSelection = nil;
        self.toDoItem.repeatSelection = nil;
    }
    
    if (source.isInEditMode == NO)
        self.toDoItem.creationDate = [DateWrapper getCurrentDate];

    if(source.isInEditMode || self.isEverythingFilter){
        [LocalNotifications editLocalNotification:item isOn:YES];
        [self printItem:item];
        [self updateSegmentControl:item];
        
        if (self.isEverythingFilter){
            // Get old and new key
            NSString *oldkey = item.listKey;
            NSString *newkey = source.selectedKey;
            
            // Get lists for old key and new key
            NSMutableArray *oldlist = [self.sharedManager.customListDictionary valueForKey:oldkey];
            NSMutableArray *newlist = [self.sharedManager.customListDictionary valueForKey:newkey];
            
            // Remove object from old list
            [oldlist removeObject:item];
            
            // Add object to new list
            if (newlist.count==0)
                newlist = [[NSMutableArray alloc]init];
            [newlist addObject:item];
            
            // Update dictionary
            [self.sharedManager.customListDictionary setObject:oldlist forKey:oldkey];
            [self.sharedManager.customListDictionary setObject:newlist forKey:newkey];
            
            // Update item with new key
            item.listKey = newkey;
        }
        if (source.isInEditMode) {
            [self updateCustomDictionary:item operation:@"edit"];
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.tableView reloadData];
            return;
        }
    }
    
    if (item != nil && item.itemName != nil){

        if(![self.selectedSegment isEqualToNumber:[NSNumber numberWithInt:0]])
        {
            [self updateSegmentControl:item];
            [ToDoItem updateSegmentForItem:item segment:self.selectedSegment];
        }
        
        if (self.toDoItem.endDate != nil)
            [LocalNotifications setLocalNotification:item isOn:source.isNotifyOn];
        
        [self.toDoItems addObject:item];
        [self.tempItems addObject:item];
        
        [self handleEditButton];
    }
    
    [self printItem:item];
    if (!self.isEverythingFilter)
        [self updateCustomDictionary:item operation:@"add"];
    
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)unWindFromShortCut:(UIStoryboardSegue*) segue{
    ReminderViewController *reminderViewController = [self.navigationController.viewControllers objectAtIndex:(2)];
    
    if ([[(UIBarButtonItem*)segue title]isEqualToString:@"Cancel"]) {
        [self.navigationController popToViewController:self animated:YES];
        [self.tableView reloadData];
        return;
    }
    
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
    
    BOOL isOn = reminderViewController.mainSwitch.isOn;
    
    [self updateSegmentControl:self.toDoItem];
    [LocalNotifications editLocalNotification:self.toDoItem isOn:isOn];
    [self printItem:self.toDoItem];
    
    [self.navigationController popToViewController:self animated:YES];
    
    [self updateCustomDictionary:self.toDoItem operation:@"edit"];
    [self.tableView reloadData];
}


-(IBAction)editButton:(id)sender{
    self.editing = !self.editing;
    [self.tableView setEditing:self.editing animated:YES];
    UIBarButtonItem *barButtonItem;
    
    
    if (self.editing){
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButton:)];

        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        [self doSingleViewAnimation:self.myToolbar animType:kCATransitionFromTop hidden:NO];
        
        self.deleteBarButton.enabled = NO;
        
        [self.selectAllButton setTitle:@"Select all"];
        self.hasSelectedAllInEdit = NO;
    }
    else{
        if(self.toDoItems.count == 0){
            //self.navigationItem.leftBarButtonItem = nil;
        }
        else
            barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButton:)];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        [self doSingleViewAnimation:self.myToolbar animType:kCATransitionFromBottom hidden:YES];
        
        [self.selectAllButton setTitle:@"Deselect all"];
        
        self.hasSelectedAllInEdit = NO;
    }
    
    NSArray *buttonArray = [NSArray arrayWithObjects:self.addUIBarButtonItem, barButtonItem, nil];
    self.navigationItem.rightBarButtonItems = buttonArray;
}

-(IBAction)deleteSelectedItems:(id)sender{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    BOOL deleteSpecificRows = selectedRows.count > 0;
    
    if(deleteSpecificRows){
        // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
        NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            [indicesOfItemsToDelete addIndex:selectionIndex.row];
        }
        NSArray *items = [self.toDoItems objectsAtIndexes:indicesOfItemsToDelete];
        // Delete the objects from our data model.
        [self.toDoItems removeObjectsAtIndexes:indicesOfItemsToDelete];
        
        // Cancel any notifications and remove from temp array.
        for (ToDoItem *item in items)
        {
            [LocalNotifications cancelLocalNotification:item];
            [self.tempItems removeObject:item];
            [self updateCustomDictionary:item operation:@"remove"];
        }
        
        // Tell the tableView that we deleted the objects
        [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    // When user has deleted, go out of edit mode.
    [self editButton:self];
    [self handleEditButton];
}

-(IBAction)selectAllItems:(id)sender{
    self.hasSelectedAllInEdit = !self.hasSelectedAllInEdit;
    
    NSString *selectText = self.hasSelectedAllInEdit ? @"Deselect all" : @"Select all";
    [self.selectAllButton setTitle:selectText];
    
    if(self.hasSelectedAllInEdit)
    {
        for (int i=0; i<self.toDoItems.count; i++) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        }
        
        self.deleteBarButton.enabled = YES;
    }
    else
    {
        for (int i=0; i<self.toDoItems.count; i++) {
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
        }
        
        self.deleteBarButton.enabled = NO;
    }
}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
    AddToDoItemViewController *addToDoItemVIewController;
    ReminderViewController *reminderViewController;
    ToDoItem *item;
 
    NSArray * sortedKeys = [[self.sharedManager.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    if ([segue.identifier isEqualToString:@"EditToDoItem"]) {
        item = [self.toDoItems objectAtIndex:self.indexPath];
        addToDoItemVIewController = (AddToDoItemViewController*)[navController topViewController];
        addToDoItemVIewController.title = @"Edit To-Do item";
        addToDoItemVIewController.isInEditMode = YES;
        addToDoItemVIewController.isFilter = self.isEverythingFilter;
        addToDoItemVIewController.toDoItem = item;
        addToDoItemVIewController.selectedKey = item.listKey;
        addToDoItemVIewController.viewController = self;
        self.viewController = addToDoItemVIewController;
    }
    else if ([segue.identifier isEqualToString:@"ReminderShortcutIdentifier"]){
        item = [self.toDoItems objectAtIndex:self.indexPath];
        reminderViewController = (ReminderViewController*)navController;
        reminderViewController.toDoItem = item;
        reminderViewController.itemname = item.itemName;
        reminderViewController.isShortcut = YES;
        reminderViewController.viewController = self;
    }
    else if([segue.identifier isEqualToString:@"AddSegue"]){
        addToDoItemVIewController = (AddToDoItemViewController*)[navController topViewController];
        addToDoItemVIewController.isInEditMode = NO;
        addToDoItemVIewController.isFilter = self.isEverythingFilter;
        if (self.selectedKey == nil)
            addToDoItemVIewController.selectedKey = [sortedKeys objectAtIndex:self.selectedListIndex];
        else
            addToDoItemVIewController.selectedKey = self.selectedKey;
        
        addToDoItemVIewController.viewController = self;
        self.viewController = addToDoItemVIewController;
    }
}


#pragma mark - UIRefreshControl Selector

- (void)toggleCells:(UIRefreshControl*)refreshControl
{
    [refreshControl beginRefreshing];

    if(!self.editing)
    {
        self.toDoItems = [self sortedItemsOnDate:self.toDoItems];
        [self.tableView reloadData];
    }
    [refreshControl endRefreshing];
}

#pragma mark - Private functions

-(void)updateSegmentControl:(ToDoItem*)item{
    BOOL isToday = false, isTomorrow = false;
    BOOL isUpcoming = false;
    
    NSDate *itemdate = [DateWrapper convertToDate:item.endDate];
    NSInteger segmentValue = [self.selectedSegment integerValue];
    
    if (segmentValue == 0 || itemdate == nil) return;
    
    NSDateComponents *itemDateComponent = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute | NSCalendarUnitHour
                                           | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:itemdate];
    
    NSDateComponents *component = [[NSDateComponents alloc]init];
    
    for(int i=0; i<2; i++)
    {
        [component setDay:i];
        
        NSDate *todayDate = [[NSCalendar currentCalendar] dateByAddingComponents:component toDate:[NSDate date] options:0];
        
        NSDateComponents *todayComponent = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute | NSCalendarUnitHour
                                            | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:todayDate];
        
        if([todayComponent day] == [itemDateComponent day] &&
           [todayComponent month] == [itemDateComponent month] &&
           [todayComponent year] == [itemDateComponent year]){
            
            if([component day]==0)
                isToday = true;
            else if([component day]==1)
                isTomorrow = true;
        }
    }
    
    if(!isToday && !isTomorrow)
        isUpcoming = true;
    
    switch (segmentValue) {
        case 1:
            // If user is on today segment and item date is tomorrow, set selected index to 2(tomorrow)
            if(isTomorrow)
                [self.segmentedControl setSelectedSegmentIndex:2];
            // If user is on today segment and item date is upcoming, set selected index to 3(upcoming)
            else if(isUpcoming)
                [self.segmentedControl setSelectedSegmentIndex:3];
            else
                // Do nothing. User is on today segment and item date is today.
            break;
        case 2:
            if(isToday)
                [self.segmentedControl setSelectedSegmentIndex:1];
            else if(isUpcoming)
                [self.segmentedControl setSelectedSegmentIndex:3];
            break;
        
        case 3:
            if(isToday)
                [self.segmentedControl setSelectedSegmentIndex:1];
            else if(isTomorrow)
                [self.segmentedControl setSelectedSegmentIndex:2];
            break;
            
        default:
            break;
    }
    
    self.selectedSegment = [NSNumber numberWithInteger:[self.segmentedControl selectedSegmentIndex]];
    [self segmentControlHandling];
}

-(void)updateCustomDictionary:(ToDoItem*)item operation:(NSString*)operation{
    NSMutableArray *list = [self.sharedManager.customListDictionary valueForKey:item.listKey];
    NSUInteger index = [list indexOfObject:item];
    
    if ([operation isEqualToString:@"remove"]) {
        [list removeObject:item];
    }
    else if ([operation isEqualToString:@"add"]){
        [list addObject:item];
    }
    else if ([operation isEqualToString:@"edit"]){
        [list replaceObjectAtIndex:index withObject:item];
    }
    
    [self.sharedManager.customListDictionary setObject:list forKey:item.listKey];
}

-(void)handleEditButton{
    if (self.isCompletedFilter)
        self.navigationItem.rightBarButtonItems = nil;
    
    else if(self.toDoItems.count == 0){
        NSArray *buttonArray = [NSArray arrayWithObjects:self.addUIBarButtonItem, nil];
        self.navigationItem.rightBarButtonItems = buttonArray;
    }
    else
    {
        UIBarButtonItem *editBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButton:)];
        
        NSArray *buttonArray = [NSArray arrayWithObjects:self.addUIBarButtonItem, editBarButtonItem, nil];
        self.navigationItem.rightBarButtonItems = buttonArray;
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
    NSString *progressText = [NSString stringWithFormat:@"%1.0f/%1.0f completed", completed, tasks];
    [self.progressText setText:progressText];
}

-(void) printItem:(ToDoItem*)item{
    // print out item
    NSLog(@"Itemid: %@\nItemname: %@\nCreation date: %@\nDue date: %@\nActual date: %@\nAlert: %@\nRepeat: %@\nSegment string id: %@\nSegment segment: %@\n", item.itemid, item.itemName, item.creationDate, item.endDate, item.actualEndDate, item.alertSelection, item.repeatSelection, item.segmentForItem.thestringid, item.segmentForItem.segment);

}

- (void) printDoToItems{
    for(ToDoItem *item in self.toDoItems){
        [self printItem:item];
        
        NSLog(@"Completed: %s", item.completed ? "YES" : "NO");
        
        NSLog(@"\n");
    }
}

-(void)doSingleViewAnimation:(UIView*)incomingView animType:(NSString*)animType hidden:(BOOL)show
{
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionPush];
    [animation setSubtype:animType];
    
    [animation setDuration:0.25];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[incomingView layer] addAnimation:animation forKey:kCATransition];
    incomingView.hidden = show;
}


-(NSMutableArray*)sortedItemsOnDate:(NSMutableArray*)items{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"actualEndDate"
                                                 ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [items sortedArrayUsingDescriptors:sortDescriptors];
    
    return [NSMutableArray arrayWithArray:sortedArray];
}

-(void)groupItems:(NSInteger)comDay segment:(NSString*)segment{
    for (ToDoItem *item in self.tempItems) {
        NSDate *itemdate = [DateWrapper convertToDate:item.endDate];
 
        // If item is placed in Today or Tomorrow, update it so it automatically updates its place.
        if(itemdate==nil && item.actualEndDate != nil){
            itemdate = item.actualEndDate;
        }
        
        // If item is placed in All or Upcoming, just keep the item there.
        if(itemdate==nil && item.actualEndDate == nil)
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
                if([today day] <= [otherDay day])
                        [self.sortedItems addObject:item];
                else if([today month] < [otherDay month])
                        [self.sortedItems addObject:item];
                else if ([today year] < [otherDay year])
                        [self.sortedItems addObject:item];
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
    
    if(self.sortedItems.count != 0)
        self.toDoItems = [self sortedItemsOnDate:self.sortedItems];
    else
        self.toDoItems = self.sortedItems;
    [self.tableView reloadData];
}

-(void)segmentControlHandling{
    self.sortedItems = [[NSMutableArray alloc]init];
    
    // All
    if([self.selectedSegment isEqualToNumber:[NSNumber numberWithInt:0]]){
        self.tempItems = [self sortedItemsOnDate:self.tempItems];
        self.toDoItems = [NSMutableArray new];
        for(ToDoItem *item in self.tempItems)
            [self.toDoItems addObject:item];
        
        [self.tableView reloadData];
    }
    
    // Today
    else if([self.selectedSegment isEqualToNumber:[NSNumber numberWithInt:1]]){
        [self groupItems:0 segment:@"segment 1"];
    }
    
    // Tomorrow
    else if([self.selectedSegment isEqualToNumber:[NSNumber numberWithInt:2]]){
        [self groupItems:1 segment:@"segment 2"];
    }
    
    // Upcoming
    else if([self.selectedSegment isEqualToNumber:[NSNumber numberWithInt:3]]){
        [self groupItems:2 segment:@"segment 3"];
    }
    
    // If user is in editmode, get out.
    if(self.editing)
        [self editButton:self];
    else
        [self handleEditButton];
}
@end
