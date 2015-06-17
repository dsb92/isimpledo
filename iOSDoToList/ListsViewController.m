//
//  ListsViewController.m
//  SimpleDo
//
//  Created by David Buhauer on 17/05/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "ListsViewController.h"
#import "ToDoListTableViewController.h"
#import "DateWrapper.h"

@interface ListsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSInteger selectedListIndex;

@end

@implementation ListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"ListsViewController: View did load");
    self.filterArray = [[NSMutableArray alloc] initWithObjects:@"Everything", nil];
    
    
    // Load custom lists
    self.customListDictionary = [[NSMutableDictionary alloc]init];
    [self loadCustomDictionary];
    
    if (self.customListDictionary.count == 0){
        NSMutableArray *newList = [[NSMutableArray alloc]init];
        [self.customListDictionary setValue:newList forKey:@"Grocery"];
        [self.customListDictionary setValue:newList forKey:@"School"];
        [self.customListDictionary setValue:newList forKey:@"Private"];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void) loadCustomDictionary{
    NSString *filePath= [self pathOfFile];
    
    NSMutableArray *listArray = [NSMutableArray arrayWithContentsOfFile:filePath];
    NSMutableArray *newList = [[NSMutableArray alloc]init];
    NSString *key;
    
    for (NSMutableArray *list in listArray) {
        key = [list objectAtIndex:0];
        for (int i=1; i<list.count; i++) {
            
            ToDoItem *item = [[ToDoItem alloc]init];
            item.segmentForItem = [[SegmentForToDoItem alloc]init];
            NSArray *array = [list objectAtIndex:i];
            
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
                
                if ([array objectAtIndex:9]!=nil) {
                    item.actualEndDate = [array objectAtIndex:9];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
            
            [newList addObject:item];
        }
        
        
        [self.customListDictionary setValue:newList forKey:key];
        newList = [[NSMutableArray alloc]init];
    }

}

- (void)applicationDidEnterBackground:(NSNotification *)notification{
    NSString *filePath= [self pathOfFile];
    
    NSArray * sortedKeys = [[self.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    NSMutableArray *listArray = [[NSMutableArray alloc]init];
    
    for(id key in sortedKeys){
        NSMutableArray *mainArray = [[NSMutableArray alloc]init];
        
        // Add key as first item (Grocery etc..)
        [mainArray addObject:key];
        // Return to do list for each key (Grocery, school, private etc.)
        id list = [self.customListDictionary objectForKey:key];
        
        for (ToDoItem *item in list) {
            NSMutableArray *array = [[NSMutableArray alloc]init];
            
            /* Non-nullable values */
            [array addObject:item.itemid];
            [array addObject:item.itemName];
            [array addObject:[NSNumber numberWithBool:item.completed]];
            [array addObject:item.creationDate];
            
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
    NSLog(@"%@", filePath);
    NSLog(@"%@", listArray);
}

-(NSString *)pathOfFile{
    // Returns an array of directories
    // App's document is the first element in this array
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path =[[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"todolist.plist"]];
    
    return path;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)unWindFromToDoList:(UIStoryboardSegue*) segue{
    ToDoListTableViewController *todoListVC = [segue sourceViewController];
    
    // If user did not tapped one of the filters
    if (todoListVC.canAddItem == true){
        
        NSArray * sortedKeys = [[self.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
        [self.customListDictionary setValue:todoListVC.tempItems forKey:[sortedKeys objectAtIndex:self.selectedListIndex]];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return self.filterArray.count;
    }
    else if (section == 1){
        return self.customListDictionary.count;
    }
    else{
        return 1;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if (indexPath.section == 0){
        cell.textLabel.text = [self.filterArray objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1){
        NSArray * sortedKeys = [[self.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
        NSLog(@"Dictionary: %@\n\n Keys: %@", self.customListDictionary, sortedKeys);
        cell.textLabel.text = [sortedKeys objectAtIndex:indexPath.row];
    }
    else {
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        NSString *filter = [self.filterArray objectAtIndex:indexPath.row];
        
        if ([filter isEqualToString:[self.filterArray lastObject]]){
            // User tapped 'Everything'
            [self performSegueWithIdentifier:@"EverythingSegue" sender:self];
        }
    }
    
    else if (indexPath.section == 1){
        self.selectedListIndex = indexPath.row;
        [self performSegueWithIdentifier:@"CustomListSegue" sender:self];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return @"Filters";
    }
    else if (section == 1){
        return @"Lists";
    }
    else{
        return @"";
    }
}
- (IBAction)NewListTapped:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Add new list" message:@"Please name your custom list:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *alertTextField = [alert textFieldAtIndex:0];
    alertTextField.placeholder = @"Enter name of list";
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *inputTitle = [[alertView textFieldAtIndex:0] text];
    if (buttonIndex == 0){
        NSLog(@"Cancel");
    }
    else{
        NSLog(@"Add");
        NSMutableArray *newList = [[NSMutableArray alloc]init];
        [self.customListDictionary setValue:newList forKey:inputTitle];
        [self.tableView reloadData];
    }
    NSLog(@"Entered: %@",inputTitle);
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ToDoListTableViewController *toDoListViewController = [segue destinationViewController];
    
    if ([segue.identifier isEqualToString:@"CustomListSegue"]){
        if(self.customListDictionary.count > 0){
            NSArray * sortedKeys = [[self.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
            toDoListViewController.title = [sortedKeys objectAtIndex:self.selectedListIndex];
            toDoListViewController.toDoItems = [self.customListDictionary valueForKey:[sortedKeys objectAtIndex:self.selectedListIndex]];
            toDoListViewController.customListDictionary = self.customListDictionary;
            toDoListViewController.selectedListIndex = self.selectedListIndex;
            toDoListViewController.canAddItem = true;
            NSLog(@"%@", toDoListViewController.toDoItems);
        }
    }
    else if ([segue.identifier isEqualToString:@"EverythingSegue"]){
        if(self.customListDictionary.count > 0){
            NSArray * sortedKeys = [[self.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
            NSMutableArray *allLists = [[NSMutableArray alloc]init];
            // Foreach key in dictionary
            for(id key in sortedKeys) {
                NSMutableArray *list = [self.customListDictionary objectForKey:key];
                [allLists addObjectsFromArray:list];
            }
            
            toDoListViewController.title = @"Everything";
            toDoListViewController.toDoItems = allLists;
            toDoListViewController.canAddItem = false;
        }
    }
}

/*
-(ToDoItem*) groupItems:(ToDoItem*) item comDay:(NSInteger)comDay segment:(NSString*)segment{
    ToDoItem *temp;
    NSDate *itemdate = [DateWrapper convertToDate:item.endDate];
    
    // If item is placed in Today or Tomorrow, update it so it automatically updates its place.
    if(itemdate==nil && item.actualEndDate != nil){
        itemdate = item.actualEndDate;
    }
    
    // If item is placed in All or Upcoming, just keep the item there.
    if(itemdate==nil && item.actualEndDate == nil)
    {
        if([item.itemid isEqualToString:item.segmentForItem.thestringid] && [item.segmentForItem.segment isEqualToString:segment]){
            temp = [[ToDoItem alloc]init];
        }
        
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
            if([today day] <= [otherDay day]){
                temp = [[ToDoItem alloc]init];
            }
            
            else if([today month] < [otherDay month]){
                temp = [[ToDoItem alloc]init];
            }
            else if ([today year] < [otherDay year]){
                temp = [[ToDoItem alloc]init];
            }
        }else{
            if([today day] == [otherDay day] &&
               [today month] == [otherDay month] &&
               [today year] == [otherDay year]){
                //do stuff
                temp = [[ToDoItem alloc]init];
            }
        }
    }
    
    return temp;
}
 */

@end
