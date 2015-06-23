//
//  ListsViewController.m
//  SimpleDo
//
//  Created by David Buhauer on 17/05/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "ListsViewController.h"
#import "ToDoListTableViewController.h"
#import "GlobalAddToDoItemViewController.h"
#import "DateWrapper.h"
#import "LocalNotifications.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self handleEditButton];
    
    // User can select list during editing but only to change the titel of the list.
    self.tableView.allowsSelectionDuringEditing = true;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *plusImage = [UIImage imageNamed:@"Big-Plus-Button.png"];

    [button setImage:plusImage forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(goToAddController) forControlEvents:UIControlEventTouchUpInside];
    
    //Clip/Clear the other pieces whichever outside the rounded corner
    button.clipsToBounds = YES;
    
    //half of the width
    int buttonSize = 60;
    button.layer.cornerRadius = buttonSize/2.0f;
    
    //border
    //button.layer.borderColor=[UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0].CGColor;
    //button.layer.borderWidth=1.0f;
    
    button.backgroundColor = [UIColor whiteColor];
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOpacity = 0.5;
    button.layer.shadowRadius = 1;
    button.layer.shadowOffset = CGSizeMake(3.0f,3.0f);
    //width and height should be same value
    button.frame = CGRectMake(self.tableView.frame.size.width-80,self.tableView.frame.size.height-140, buttonSize,buttonSize);
    button.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    button.showsTouchWhenHighlighted = YES;
    
    button.layer.masksToBounds = NO;
    // Bottom right corner
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleTopMargin;

    [self.tableView addSubview:button];
}

-(void)goToAddController{
    [self performSegueWithIdentifier:@"GlobalAddSegue" sender:self];
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
                
                // get list key
                if ([array objectAtIndex:4]!=nil) {
                    item.listKey = [array objectAtIndex:4];
                }
                
                // get segment string id for to-do item
                if ([array objectAtIndex:5]!=nil) {
                    item.segmentForItem.thestringid = [array objectAtIndex:5];
                }
                
                // get segment segment for to-do item
                if ([array objectAtIndex:6]!=nil) {
                    item.segmentForItem.segment = [array objectAtIndex:6];
                }
                
                // get end date
                if ([array objectAtIndex:7]!=nil) {
                    item.endDate = [array objectAtIndex:7];
                }
                
                // get alert selection
                if ([array objectAtIndex:8]!=nil) {
                    item.alertSelection = [array objectAtIndex:8];
                }
                
                // get repeat selection
                if ([array objectAtIndex:9]!=nil) {
                    item.repeatSelection = [array objectAtIndex:9];
                }
                
                if ([array objectAtIndex:10]!=nil) {
                    item.actualEndDate = [array objectAtIndex:10];
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
    
    [self saveCustomDictionary];
    [self updateNotificationBadge];
    
    
}

- (void)applicationDidBecomeActive:(NSNotification *)notification{
    [self.tableView reloadData];
}

-(void)saveCustomDictionary{
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
    NSLog(@"%@", filePath);
    NSLog(@"%@", listArray);

}

-(void)updateNotificationBadge{
    NSArray * sortedKeys = [[self.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    // How many items have exceeded the current date(if any reminder given)
    NSUInteger count = 0;
    // Foreach key in dictionary
    for(id key in sortedKeys) {
        NSMutableArray *list = [self.customListDictionary objectForKey:key];
        
        NSDate *currentDate = [DateWrapper convertToDate:[DateWrapper getCurrentDate]];
        
        for (ToDoItem *item in list) {
            if(!item.completed && ([item.alertSelection length] != 0 || ![item.alertSelection isEqualToString:@"None"])){
                NSDate *itemDueDate = [DateWrapper convertToDate:item.endDate];
                if(itemDueDate==nil)continue;
                
                if([currentDate compare:itemDueDate] == NSOrderedDescending || [currentDate compare:itemDueDate] == NSOrderedSame){
                    count++;
                }
            }
        }
        
        // clear the badge on the icon
        //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
        // The following code renumbers the badges of pending notifications (in case user deletes or changes some local notifications while the app was running). So the following code runs, when the user
        // gets out of the app.
        
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
                
                // Dont schedule again for "old" fire dates (with repeatIntervals set)
                if([[NSDate date] compare:notification.fireDate] == NSOrderedDescending || [[NSDate date] compare:notification.fireDate] == NSOrderedSame) continue;
                
                notification.applicationIconBadgeNumber = badgeNbr+count;
                badgeNbr++;
                
                // schedule 'again'
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
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
    
    if (todoListVC.isEverythingFilter || todoListVC.isCompletedFilter){
        self.customListDictionary = todoListVC.customListDictionary;
    }
    else{
        NSArray * sortedKeys = [[self.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
        [self.customListDictionary setValue:todoListVC.tempItems forKey:[sortedKeys objectAtIndex:self.selectedListIndex]];
    }
    
    [self.tableView reloadData];
}

-(IBAction)unWindFromGlobalAdd:(UIStoryboardSegue*) segue{
    GlobalAddToDoItemViewController *globalAddViewController = [segue sourceViewController];
    
    if(globalAddViewController.didCancel) return;
    
    NSMutableArray *list = [self.customListDictionary valueForKey:globalAddViewController.selectedKey];
    ToDoItem *newItemToAdd = globalAddViewController.toDoItem;
    bool isNotifyOn = globalAddViewController.isNotifyOn;

    if(globalAddViewController.isInEditMode){
        if (globalAddViewController.didCancel == NO){
            [LocalNotifications editLocalNotification:newItemToAdd isOn:YES];
            [self.tableView reloadData];
        }
        return;
    }
    
    if (newItemToAdd != nil && newItemToAdd.itemName != nil){
        
        if (newItemToAdd.endDate != nil)
            [LocalNotifications setLocalNotification:newItemToAdd isOn:isNotifyOn];
        
        newItemToAdd.listKey = globalAddViewController.selectedKey;
        [list addObject:newItemToAdd];
        
        NSLog(@"Added item: %@ to list: %@", newItemToAdd, globalAddViewController.selectedKey);
        
        [self.customListDictionary setValue:list forKey:globalAddViewController.selectedKey];
        
        [self handleEditButton];
        [self.tableView reloadData];
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
    
    NSUInteger listCount;
    NSArray * sortedKeys = [[self.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    if (indexPath.section == 0){
        cell.textLabel.text = [self.filterArray objectAtIndex:indexPath.row];
        
        NSMutableArray *allLists = [[NSMutableArray alloc]init];
        // Foreach key in dictionary
        for(id key in sortedKeys) {
            NSMutableArray *list = [self.customListDictionary objectForKey:key];
            [allLists addObjectsFromArray:list];
        }
        
        listCount = allLists.count;
        
        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"%lu", (unsigned long)listCount];
        label.textColor = [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0];
        [label setFrame:cell.frame];
        label.numberOfLines = 0;
        [label setTextAlignment:NSTextAlignmentRight];
        // Bottom right corner
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleTopMargin;
        [cell.contentView addSubview:label];
    }
    else if (indexPath.section == 1){
        NSLog(@"Dictionary: %@\n\n Keys: %@", self.customListDictionary, sortedKeys);
        cell.textLabel.text = [sortedKeys objectAtIndex:indexPath.row];
        
        NSMutableArray *list = [self.customListDictionary valueForKey:sortedKeys[indexPath.row]];
        
        listCount = [[self.customListDictionary valueForKey:[sortedKeys objectAtIndex:indexPath.row]] count];
        
        bool hasAnyOutDated = [self hasAnyOutdated:list];
        
        if (hasAnyOutDated){
            UILabel *label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"%lu !", (unsigned long)listCount];
            
            NSMutableAttributedString *text =
            [[NSMutableAttributedString alloc]
             initWithAttributedString: label.attributedText];
            
            [text addAttribute:NSForegroundColorAttributeName
                         value:[UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
                         range:NSMakeRange(0, 1)];
            
            [text addAttribute:NSForegroundColorAttributeName
                         value:[UIColor redColor]
                         range:NSMakeRange(2, 1)];
            [label setAttributedText: text];
            
            [label setFrame:cell.frame];
            label.numberOfLines = 0;
            [label setTextAlignment:NSTextAlignmentRight];
            label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleTopMargin;
            [cell.contentView addSubview:label];
        }
        else{
            UILabel *label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"%lu", (unsigned long)listCount];
            label.textColor = [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0];
            [label setFrame:cell.frame];
            label.numberOfLines = 0;
            [label setTextAlignment:NSTextAlignmentRight];
            label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleTopMargin;
            [cell.contentView addSubview:label];
        }
        
    }
    else {
        cell.textLabel.text = @"Completed tasks";
        
        NSMutableArray *allLists = [[NSMutableArray alloc]init];
        // Foreach key in dictionary
        for(id key in sortedKeys) {
            NSMutableArray *list = [self.customListDictionary objectForKey:key];
            [allLists addObjectsFromArray:list];
        }
        
        int completed = 0;
        for(ToDoItem *item in allLists){
            if (item.completed)
                completed++;
        }
        
        listCount = completed;

        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"%lu", (unsigned long)listCount];
        label.textColor = [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0];
        [label setFrame:cell.frame];
        label.numberOfLines = 0;
        [label setTextAlignment:NSTextAlignmentRight];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleTopMargin;
        [cell.contentView addSubview:label];
    }
    /*
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"%lu", (unsigned long)listCount];
    label.textColor = [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0];
    [label setFrame:cell.frame];
    label.numberOfLines = 0;
    [label setTextAlignment:NSTextAlignmentRight];

    [cell.contentView addSubview:label];
    */
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(bool) hasAnyOutdated:(NSMutableArray*)list{
    bool hasAnyOutDated = false;
    
    for(ToDoItem* item in list){
        NSDate *currentDate = [DateWrapper convertToDate:[DateWrapper getCurrentDate]];
        NSDate *itemDueDate = [DateWrapper convertToDate:item.endDate];
        
        if(itemDueDate==nil){
            continue;
        }
        // If current date is greater than item's due date
        if([currentDate compare:itemDueDate] == NSOrderedDescending || [currentDate compare:itemDueDate] == NSOrderedSame)
        {
            hasAnyOutDated = true;
            return hasAnyOutDated;
        }
        else{
            hasAnyOutDated = false;
            return hasAnyOutDated;
        }
    }
    
    return hasAnyOutDated;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // If not editing
    if (!self.editing){
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
        else{
            [self performSegueWithIdentifier:@"CompletedSegue" sender:self];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    // If editing
    else {
        if (indexPath.section == 0) return;
        
        else if (indexPath.section == 1){
            NSArray * sortedKeys = [[self.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
            NSString *oldKey = [sortedKeys objectAtIndex:indexPath.row];
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Edit list"
                                          message:@"Rename your custom list:"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           //Do Some action here
                                                           
                                                           NSString *inputTitle = ((UITextField *)[alert.textFields objectAtIndex:0]).text;
                                                           // Set current object for old key with new key (which is not empty or equal to old key)
                                                           if (![inputTitle isEqualToString:@""] && ![inputTitle isEqualToString:oldKey])
                                                           {
                                                               [self.customListDictionary setObject:[self.customListDictionary objectForKey:oldKey] forKey:inputTitle];
                                                               // Delete object for old key.
                                                               [self.customListDictionary removeObjectForKey:oldKey];
                                                               NSLog(@"Changed list titel");
                                                               [self.tableView reloadData];
                                                           }
                                                           
                                                           
                                                       }];
            UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               NSLog(@"Cancel");
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];
            
            [alert addAction:ok];
            [alert addAction:cancel];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Rename list";
                textField.text = oldKey;
            }];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0) return NO;
    
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray * sortedKeys = [[self.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    NSMutableArray *list = [self.customListDictionary valueForKey:[sortedKeys objectAtIndex:indexPath.row]];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete local notifications if any
        
        for(ToDoItem *item in list)
            [LocalNotifications cancelLocalNotification:item];
        
        [self.customListDictionary removeObjectForKey:[sortedKeys objectAtIndex:indexPath.row]];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self handleEditButton];
        [self.tableView reloadData];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
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

- (IBAction)NewListTapped:(id)sender {
    /*
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Add new list" message:@"Please name your custom list:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *alertTextField = [alert textFieldAtIndex:0];
    alertTextField.placeholder = @"Enter name of list";
    [alert show];
     */
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Add new list"
                                  message:@"Please name your custom list:"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   //Do Some action here
                                                   NSLog(@"Add");
                                                   NSString *inputTitle = ((UITextField *)[alert.textFields objectAtIndex:0]).text;
                                                   
                                                   NSMutableArray *newList = [[NSMutableArray alloc]init];
                                                   [self.customListDictionary setValue:newList forKey:inputTitle];
                                                   [self handleEditButton];
                                                   [self.tableView reloadData];
                                                   
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       NSLog(@"Cancel");
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Enter name of list";
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)handleEditButton{
    if(self.customListDictionary.count == 0){
        self.navigationItem.leftBarButtonItem = nil;
    }
    else
    {
        UIBarButtonItem *editBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTapped:)];
        
        self.navigationItem.leftBarButtonItem = editBarButtonItem;
    }
}

- (IBAction)editTapped:(id)sender {
    self.editing = !self.editing;
    [self.tableView setEditing:self.editing animated:YES];
    UIBarButtonItem *barButtonItem;
    
    
    if (self.editing){
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editTapped:)];
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else{
        if(self.customListDictionary.count == 0){
            //self.navigationItem.leftBarButtonItem = nil;
        }
        else
            barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTapped:)];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    self.navigationItem.leftBarButtonItem = barButtonItem;
}
/*
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
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ToDoListTableViewController *toDoListViewController = [segue destinationViewController];
    
    NSArray * sortedKeys = [[self.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    if ([segue.identifier isEqualToString:@"CustomListSegue"]){
        if(self.customListDictionary.count > 0){
            toDoListViewController.title = [sortedKeys objectAtIndex:self.selectedListIndex];
            toDoListViewController.toDoItems = [self.customListDictionary valueForKey:[sortedKeys objectAtIndex:self.selectedListIndex]];
            toDoListViewController.customListDictionary = self.customListDictionary;
            toDoListViewController.selectedListIndex = self.selectedListIndex;
            toDoListViewController.listKey = [sortedKeys objectAtIndex:self.selectedListIndex];
            toDoListViewController.isEverythingFilter = false;
            toDoListViewController.isCompletedFilter = false;
            NSLog(@"%@", toDoListViewController.toDoItems);
        }
    }
    else if ([segue.identifier isEqualToString:@"EverythingSegue"]){
        if(self.customListDictionary.count > 0){
            NSMutableArray *allLists = [[NSMutableArray alloc]init];
            // Foreach key in dictionary
            for(id key in sortedKeys) {
                NSMutableArray *list = [self.customListDictionary objectForKey:key];
                [allLists addObjectsFromArray:list];
            }
            
            toDoListViewController.title = @"Everything";
            toDoListViewController.toDoItems = allLists;
            toDoListViewController.customListDictionary = self.customListDictionary;
            toDoListViewController.isEverythingFilter = true;
            toDoListViewController.isCompletedFilter = false;
        }
    }
    
    else if ([segue.identifier isEqualToString:@"CompletedSegue"]){
        if(self.customListDictionary.count > 0){
            NSMutableArray *allLists = [[NSMutableArray alloc]init];
            NSMutableArray *completedList = [[NSMutableArray alloc]init];
            // Foreach key in dictionary
            for(id key in sortedKeys) {
                NSMutableArray *list = [self.customListDictionary objectForKey:key];
                [allLists addObjectsFromArray:list];
            }
            
            for(ToDoItem *item in allLists){
                if (item.completed)
                    [completedList addObject:item];
            }
            
            toDoListViewController.title = @"Completed tasks";
            toDoListViewController.toDoItems = completedList;
            toDoListViewController.customListDictionary = self.customListDictionary;
            toDoListViewController.isEverythingFilter = false;
            toDoListViewController.isCompletedFilter = true;
            
            NSLog(@"Completed tasks list: %@", completedList);
        }
    }
    
    else if ([segue.identifier isEqualToString:@"GlobalAddSegue"]){
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        GlobalAddToDoItemViewController *globalAddViewController = (GlobalAddToDoItemViewController*)[navController topViewController];
        globalAddViewController.customListDictionary = self.customListDictionary;
        globalAddViewController.selectedKey = [sortedKeys objectAtIndex:0];
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
