    //
//  ListsViewController.m
//  SimpleDo
//
//  Created by David Buhauer on 17/05/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "ListsViewController.h"
#import "ToDoListTableViewController.h"
#import "AddToDoItemViewController.h"
#import "SWRevealViewController.h"
#import "DateWrapper.h"
#import "LocalNotifications.h"
#import "ParseCloud.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "CustomListManager.h"

@interface ListsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSInteger selectedListIndex;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addListBarbuttonItem;
@property UIButton *bigPlusButton;
@property CustomListManager *sharedManager;
@property(nonatomic, strong) GADInterstitial *interstitial;
@property UIBarButtonItem *barButton;

@end

@implementation ListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initial singleton
    self.sharedManager = [CustomListManager sharedManager];
    
    NSLog(@"ListsViewController: View did load");
    self.filterArray = [[NSMutableArray alloc] initWithObjects:@"Everything", nil];
    
    // Load custom lists
    if ([ParseCloud cloudEnabled]){
        [self loadFromCloud];
    }
    else{
        [ToDoItem loadFromLocal];
    }
    
    if (self.sharedManager.customListDictionary.count == 0){
        NSMutableArray *newList = [[NSMutableArray alloc]init];
        [self.sharedManager.customListDictionary setValue:newList forKey:@"Grocery"];
        [self.sharedManager.customListDictionary setValue:newList forKey:@"Job"];
        [self.sharedManager.customListDictionary setValue:newList forKey:@"Private"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(disableUserInteraction) name:@"MenuOpen" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enableUserInteraction) name:@"MenuClosed" object:nil];
    
    [self handleEditButton];
    
    // Conflicts with uitableview cells on swipe.
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // User can select list during editing but only to change the titel of the list.
    self.tableView.allowsSelectionDuringEditing = true;
    
    // Menu button which navigates to slider menu
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuBtn setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    [menuBtn addTarget:self.viewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    menuBtn.frame = CGRectMake(0, 0, 30, 30);
    self.barButton = [[UIBarButtonItem alloc]initWithCustomView:menuBtn];
    
    // Big plus button
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
    button.frame = CGRectMake((self.navigationController.view.frame.size.width/2)-(buttonSize/2),self.navigationController.view.frame.size.height-(buttonSize*2), buttonSize,buttonSize);
    button.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    button.showsTouchWhenHighlighted = YES;
    
    button.layer.masksToBounds = NO;
    // Bottom right corner
    //button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleTopMargin;

    [self.navigationController.view addSubview:button];
    
    self.bigPlusButton = button;
    // Print notifications and dictionary
    [self print];
}

-(void)viewWillAppear:(BOOL)animated{
    [self initializeBanner];
    
    [self initializeInterstitials];
    
    [self initializeLeftBarButtons];
}

-(void)initializeBanner{
    
    BOOL removeAds = [[NSUserDefaults standardUserDefaults]boolForKey:@"removeAds"];
    
    if (removeAds){
        self.bannerView.hidden = true;
    }
    else{
        NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
        
        // Test Version
        self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
        
        // Live version
        //self.bannerView.adUnitID = @"ca-app-pub-2595377837159656/7156429321";
        
        self.bannerView.rootViewController = self;
        
        GADRequest *request = [GADRequest request];
        // Requests test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made. GADBannerView automatically returns test ads when running on a
        // simulator.
        request.testDevices = @[
                                @"9d76e2f8ed01fcade9b41f4fea72a5c7"  // Davids iPhone
                                ];
        [self.bannerView loadRequest:request];
    }
}

-(void)initializeInterstitials{
    
    BOOL removeAds = [[NSUserDefaults standardUserDefaults]boolForKey:@"removeAds"];
    
    if (!removeAds){
        // Test version
        self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3940256099942544/4411468910"];
        
        // Live version
        //self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"cca-app-pub-2595377837159656/2028225729"];
        
        GADRequest *request = [GADRequest request];
        // Requests test ads on test devices.
        request.testDevices = @[@"9d76e2f8ed01fcade9b41f4fea72a5c7"]; // Davids iPhone
        [self.interstitial loadRequest:request];
    }
}

-(void)initializeLeftBarButtons{

    UIBarButtonItem *syncingButton = [[UIBarButtonItem alloc]init];

    if ([ParseCloud cloudEnabled]){
        [syncingButton setTitle:@"Cloud: ON"];
    }
    else{
        [syncingButton setTitle:@"Cloud: OFF"];
    }
    
    syncingButton.enabled = false;
    
    NSArray *buttonArray = [NSArray arrayWithObjects:self.barButton, syncingButton, nil];
    self.navigationItem.leftBarButtonItems = buttonArray;
}

-(void)enableUserInteraction{
    self.tableView.userInteractionEnabled = true;
}

-(void)disableUserInteraction{
    self.tableView.userInteractionEnabled = false;
}

-(void)saveToParse:(UIApplication *)application{
    if ([ParseCloud cloudEnabled]){
        [ParseCloud saveToCloud:self.sharedManager.customListDictionary];
    }
}

-(void)goToAddController{
    [self performSegueWithIdentifier:@"GlobalAddSegue" sender:self];
}

-(void)print{
    NSLog(@"Local notifications:\n");
    
    for(UILocalNotification *localN in [[UIApplication sharedApplication]scheduledLocalNotifications])
        NSLog(@"%@", localN);
    
    NSArray * sortedKeys = [[self.sharedManager.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    NSLog(@"Dictionary: %@\n\n Keys: %@", self.sharedManager.customListDictionary, sortedKeys);
}

-(void)loadFromCloud{
    
    // Load array from the cloud
    [ParseCloud loadFromCloud:^(NSMutableArray *listArray) {
        NSMutableDictionary *listDictionary = [listArray objectAtIndex:0];
        
        // Get the keys
        NSArray * sortedKeys = [[listDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
        
        // From each key (Grocery e.g.) deserialize the value (ToDoItems)
        for (id key in sortedKeys) {
            NSMutableArray *toDoListArrayWithDictionaries = [listDictionary objectForKey:key];
            NSMutableArray *myToDoItems = [[NSMutableArray alloc]init];
            NSError *error;
            // From each item expressed as a dictionary, deserialize it to a ToDoItem object
            for(id itemStr in toDoListArrayWithDictionaries){
                NSData *data = [itemStr dataUsingEncoding:NSUTF8StringEncoding];
                NSMutableDictionary *toDoDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                
                ToDoItem *toDoItem = [[ToDoItem alloc]init];
                
                toDoItem.itemid = toDoDictionary[@"itemid"];
                toDoItem.itemName = toDoDictionary[@"itemName"];
                toDoItem.completed = [toDoDictionary[@"completed"] boolValue];
                toDoItem.creationDate = toDoDictionary[@"creationDate"];
                toDoItem.listKey = toDoDictionary[@"listKey"];
                toDoItem.segmentForItem.thestringid = toDoDictionary[@"thestringid"];
                toDoItem.segmentForItem.segment = toDoDictionary[@"segment"];
                toDoItem.endDate = toDoDictionary[@"endDate"];
                toDoItem.alertSelection = toDoDictionary[@"alertSelection"];
                toDoItem.repeatSelection = toDoDictionary[@"repeatSelection"];
                
                toDoItem.actualEndDate = [DateWrapper convertToDate:toDoDictionary[@"actualEndDate"]];
                
                // Add deserialized item to array of ToDoItems objects
                [myToDoItems addObject:toDoItem];

            }
            
            // Set deserialized item array with to do items to this key
            [self.sharedManager.customListDictionary setObject:myToDoItems forKey:key];
            
            // Reset
            toDoListArrayWithDictionaries = nil;
            myToDoItems = nil;
        }
        
        // Print it all out
        [self print];
        
        // Reload view
        [self.tableView reloadData];
    }];

}



- (void)applicationDidEnterBackground:(NSNotification *)notification{
    
    
    
}

- (void)applicationDidBecomeActive:(NSNotification *)notification{
    [self.tableView reloadData];
}

-(IBAction)unWindFromToDoList:(UIStoryboardSegue*) segue{
    ToDoListTableViewController *todoListVC = [segue sourceViewController];
    
    if (todoListVC.isEverythingFilter || todoListVC.isCompletedFilter){
        
    }
    else{
        NSArray * sortedKeys = [[self.sharedManager.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
        [self.sharedManager.customListDictionary setValue:todoListVC.tempItems forKey:[sortedKeys objectAtIndex:self.selectedListIndex]];
    }
    
    [self.tableView reloadData];
    
    // Maybe show interstitials
    [self tryShowInterstitials];
}

-(void)tryShowInterstitials{

    int minSessions = 3;
    int tryAgainSession = 6;
    
    BOOL removeAds = [[NSUserDefaults standardUserDefaults] boolForKey:@"removeAds"];
    long numLaunches = [[NSUserDefaults standardUserDefaults] integerForKey:@"interstitialsLaunches"] + 1;
    
    if (!removeAds && (numLaunches == minSessions || numLaunches >= (minSessions + tryAgainSession + 1))){
        if ([self.interstitial isReady]) {
            NSLog(@"****LOADING INTERSTITIALS!****");
            [self.interstitial presentFromRootViewController:self];
        }
        
        numLaunches = minSessions + 1;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:numLaunches forKey:@"interstitialsLaunches"];
    
}

-(void)interstitialDidDismissScreen:(GADInterstitial *)ad{
    [self initializeInterstitials];
}


-(IBAction)unWindFromGlobalAdd:(UIStoryboardSegue*) segue{
    if([[(UIBarButtonItem*)segue title]isEqualToString:@"Cancel"]){
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    AddToDoItemViewController *globalAddViewController = (AddToDoItemViewController*)self.viewController;
    
    if (globalAddViewController.dueDateLabel.text.length == 0){
        globalAddViewController.toDoItem.endDate = nil;
        globalAddViewController.toDoItem.alertSelection = nil;
        globalAddViewController.toDoItem.repeatSelection = nil;
    }
    
    // get to do item name from textfield
    if (globalAddViewController.textField.text.length > 0) {
        // Cancel any local notifaction attached to the old item name contained in dictionary.
        if(globalAddViewController.isInEditMode && [globalAddViewController.toDoItem.endDate length] != 0)
            [LocalNotifications cancelLocalNotification:globalAddViewController.toDoItem];
        globalAddViewController.toDoItem.itemName = globalAddViewController.textField.text;
        globalAddViewController.toDoItem.completed = false;
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    // Create the item and store in the dictionary with the selected key
    globalAddViewController.toDoItem.creationDate = [DateWrapper getCurrentDate];
    
    NSMutableArray *list = [self.sharedManager.customListDictionary valueForKey:globalAddViewController.selectedKey];
    
    if (list.count == 0)
        list = [[NSMutableArray alloc]init];
    
    
    ToDoItem *newItemToAdd = globalAddViewController.toDoItem;
    bool isNotifyOn = globalAddViewController.isNotifyOn;

    // Add item and set notifications if set and update dictionary for selected key.
    if (newItemToAdd != nil && newItemToAdd.itemName != nil){
        
        if (newItemToAdd.endDate != nil)
            [LocalNotifications setLocalNotification:newItemToAdd isOn:isNotifyOn];
        
        newItemToAdd.listKey = globalAddViewController.selectedKey;
        [list addObject:newItemToAdd];
        
        NSLog(@"Added item: %@ to list: %@", newItemToAdd, globalAddViewController.selectedKey);
        
        [self.sharedManager.customListDictionary setObject:list forKey:globalAddViewController.selectedKey];
        
        // Remember selected key choice
        self.selectedKey = newItemToAdd.listKey;
        
        [self handleEditButton];
        [self.tableView reloadData];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    // Maybe show interstitials
    [self tryShowInterstitials];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return self.filterArray.count;
    }
    else if (section == 1){
        return self.sharedManager.customListDictionary.count;
    }
    else{
        return 1;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    NSUInteger listCount;
    NSArray * sortedKeys = [[self.sharedManager.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    if (indexPath.section == 0){
        cell.textLabel.text = [self.filterArray objectAtIndex:indexPath.row];
        
        NSMutableArray *allLists = [[NSMutableArray alloc]init];
        // Foreach key in dictionary
        for(id key in sortedKeys) {
            NSMutableArray *list = [self.sharedManager.customListDictionary objectForKey:key];
            
            for (ToDoItem *item in list) {
                if (!item.completed) {
                    [allLists addObject:item];
                }
            }
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
        cell.textLabel.text = [sortedKeys objectAtIndex:indexPath.row];
        
        NSMutableArray *allItemsForKey = [self.sharedManager.customListDictionary valueForKey:sortedKeys[indexPath.row]];
        
        NSMutableArray *list = [[NSMutableArray alloc]init];
        
        for (ToDoItem *item in allItemsForKey) {
            if (!item.completed) {
                [list addObject:item];
            }
        }
        
        listCount = list.count;
        
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
            NSMutableArray *list = [self.sharedManager.customListDictionary objectForKey:key];
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
            NSArray * sortedKeys = [[self.sharedManager.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
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
                                                               [self.sharedManager.customListDictionary setObject:[self.sharedManager.customListDictionary objectForKey:oldKey] forKey:inputTitle];
                                                               // Delete object for old key.
                                                               [self.sharedManager.customListDictionary removeObjectForKey:oldKey];
                                                               
                                                               for (ToDoItem *item in [self.sharedManager.customListDictionary valueForKey:inputTitle]){
                                                                   item.listKey = inputTitle;
                                                               }
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
    if (indexPath.section == 0)
        return NO;
    else if (indexPath.section == 1)
        return YES;
    else if (indexPath.section == 2)
        return NO;
    else
        return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray * sortedKeys = [[self.sharedManager.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    NSMutableArray *list = [self.sharedManager.customListDictionary valueForKey:[sortedKeys objectAtIndex:indexPath.row]];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete local notifications if any
        
        for(ToDoItem *item in list){
            [LocalNotifications cancelLocalNotification:item];
        }
        
        [list removeAllObjects];
        
        [self.sharedManager.customListDictionary removeObjectForKey:[sortedKeys objectAtIndex:indexPath.row]];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (self.editing)
            [self editTapped:self];
        [self handleEditButton];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ListUpdated"
         object:self];
        
        [self.tableView reloadData];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == 0){
        return @"Filter";
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
                                                   [self.sharedManager.customListDictionary setValue:newList forKey:inputTitle];
                                                   [self handleEditButton];
                                                   
                                                   [[NSNotificationCenter defaultCenter]
                                                    postNotificationName:@"ListUpdated"
                                                    object:self];
                                                   
                                                   [self.tableView reloadData];
                                                   
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
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
    if(self.sharedManager.customListDictionary.count == 0){
        NSArray *buttonArray = [NSArray arrayWithObjects:self.addListBarbuttonItem, nil];
        self.navigationItem.rightBarButtonItems = buttonArray;
    }
    else
    {
        UIBarButtonItem *editBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTapped:)];
        
        NSArray *buttonArray = [NSArray arrayWithObjects:self.addListBarbuttonItem, editBarButtonItem, nil];
        self.navigationItem.rightBarButtonItems = buttonArray;
    }
}

- (IBAction)editTapped:(id)sender {
    self.editing = !self.editing;
    [self.tableView setEditing:self.editing animated:YES];
    UIBarButtonItem *barButtonItem;
    
    
    if (self.editing){
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editTapped:)];
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.bigPlusButton.enabled = false;
        
    }
    else{
        if(self.sharedManager.customListDictionary.count == 0){
            //self.navigationItem.rightBarButtonItem = nil;
        }
        else
            barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTapped:)];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.bigPlusButton.enabled = true;
    }
    
    NSArray *buttonArray = [NSArray arrayWithObjects:self.addListBarbuttonItem, barButtonItem, nil];
    self.navigationItem.rightBarButtonItems = buttonArray;
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
    
    NSArray * sortedKeys = [[self.sharedManager.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    if ([segue.identifier isEqualToString:@"CustomListSegue"]){
        if(self.sharedManager.customListDictionary.count > 0){
            toDoListViewController.title = [sortedKeys objectAtIndex:self.selectedListIndex];
            toDoListViewController.toDoItems = [self.sharedManager.customListDictionary valueForKey:[sortedKeys objectAtIndex:self.selectedListIndex]];
            toDoListViewController.selectedListIndex = self.selectedListIndex;
            toDoListViewController.selectedKey = [sortedKeys objectAtIndex:self.selectedListIndex];
            toDoListViewController.isEverythingFilter = false;
            toDoListViewController.isCompletedFilter = false;
            NSLog(@"%@", toDoListViewController.toDoItems);
        }
    }
    else if ([segue.identifier isEqualToString:@"EverythingSegue"]){
        if(self.sharedManager.customListDictionary.count > 0){
            NSMutableArray *allLists = [[NSMutableArray alloc]init];
            // Foreach key in dictionary
            for(id key in sortedKeys) {
                NSMutableArray *list = [self.sharedManager.customListDictionary objectForKey:key];
                [allLists addObjectsFromArray:list];
            }
            
            toDoListViewController.title = @"Everything";
            toDoListViewController.toDoItems = allLists;
            toDoListViewController.isEverythingFilter = true;
            toDoListViewController.isCompletedFilter = false;
        }
    }
    
    else if ([segue.identifier isEqualToString:@"CompletedSegue"]){
        if(self.sharedManager.customListDictionary.count > 0){
            NSMutableArray *allLists = [[NSMutableArray alloc]init];
            NSMutableArray *completedList = [[NSMutableArray alloc]init];
            // Foreach key in dictionary
            for(id key in sortedKeys) {
                NSMutableArray *list = [self.sharedManager.customListDictionary objectForKey:key];
                [allLists addObjectsFromArray:list];
            }
            
            for(ToDoItem *item in allLists){
                if (item.completed)
                    [completedList addObject:item];
            }
            
            toDoListViewController.title = @"Completed tasks";
            toDoListViewController.toDoItems = completedList;
            toDoListViewController.isEverythingFilter = false;
            toDoListViewController.isCompletedFilter = true;
            
            NSLog(@"Completed tasks list: %@", completedList);
        }
    }
    
    else if ([segue.identifier isEqualToString:@"GlobalAddSegue"]){
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        AddToDoItemViewController *globalAddViewController = (AddToDoItemViewController*)[navController topViewController];
        
        if (self.selectedKey == nil || [self.selectedKey isEqualToString:@""])
            globalAddViewController.selectedKey = [sortedKeys objectAtIndex:0];
        else{
            NSArray * sortedKeys = [[self.sharedManager.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
            
            BOOL isKeyValid = false;
            for(id key in sortedKeys)
            {
                if([key isEqualToString:self.selectedKey])
                    isKeyValid = true;
            }
            
            if (isKeyValid) {
                globalAddViewController.selectedKey = self.selectedKey;
            }
            else{
                globalAddViewController.selectedKey = [sortedKeys objectAtIndex:0];
            }
        }
        
        globalAddViewController.isGlobal = YES;
        globalAddViewController.viewController = self;
        
        self.viewController = globalAddViewController;
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
