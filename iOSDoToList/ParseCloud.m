//
//  ParseCloud.m
//  SimpleDo
//
//  Created by David Buhauer on 04/10/2015.
//  Copyright © 2015 David Buhauer. All rights reserved.
//

#import "ParseCloud.h"


@implementation ParseCloud


+(void)saveToCloud:(NSMutableDictionary*)customListDictionary{
    
    // Get the user
    PFUser *currentUser = [PFUser currentUser];
    
    // Check if not null
    if (currentUser){
    
        // Check if there is an existing Lists on the cloud
        PFQuery *query = [PFQuery queryWithClassName:@"Lists"];
        [query whereKey:@"username" equalTo:currentUser.username];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error){
            
            // If no errors finding existing lists
            if (error == nil){
                
                // Delete each list
                for (id obj in objects){
                    
                    [self deleteExistingList:obj];
                    
                }
                
                // Create a new list
                [self saveNewList:customListDictionary];
                
            }
            else{
                
                NSLog(@"Error finding existing lists : %@", error.description);
      
            }
            
        }];

    }
}

+(void)saveNewList:(NSMutableDictionary*)dictionary{
    
    PFUser *currentUser = [PFUser currentUser];
    
    
    // Get the keys
    NSArray * sortedKeys = [[dictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    // Foreach key in the dictionary (Grocery etc)
    for(id key in sortedKeys){
        
        // Foreach key create new list with name of the key
        PFObject *list = [PFObject objectWithClassName:@"Lists"];
        
        list[@"username"] = currentUser.username;
        list[@"listkey"] = key;

        // Save the list
        [list saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
           
            if (error == nil){
                
                NSLog(@"List with key %@ saved to the cloud", key);
                
                // Iterate through each item in the list
                [self iterateEachToDo:dictionary key:key list:list];
                
            }
            else{
                
                NSLog(@"Error saving list with key %@: %@", key, error.description);
                
            }
            
        }];
    
    }
 
}

+(void)deleteExistingList:(PFObject*)list{
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Items"];
    [query whereKey:@"list" equalTo:list];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (objects.count == 0){
            
            NSLog(@"No items found");
            
        }
        
        // Delete the items associated with the list
        for(PFObject *obj in objects){
            
            [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                NSLog(@"Succesfully deleted item associated with list %@", list[@"listkey"]);
                
            }];
            
        }
        
        // Delete the list
        [list deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
            if (succeeded){
                
                NSLog(@"Succesfully deleted list associated with user %@", currentUser.username);
                
            }
            
        }];
        
    }];
    
    
}

+(void)iterateEachToDo:(NSMutableDictionary*)dictionary key:(NSString*)key list:(PFObject*)list{
    
    // Return to do list for each key (Grocery, school, private etc.)
    id items = [dictionary objectForKey:key];
    
    for(ToDoItem *item in items){
        
        // Create an item
        /* Non-nullable values */
        PFObject *itemToSave = [PFObject objectWithClassName:@"Items"];
        
        itemToSave[@"list"] = list;
        itemToSave[@"itemid"] = item.itemid;
        itemToSave[@"itemname"] = item.itemName;
        itemToSave[@"completed"] = [NSNumber numberWithBool:item.completed];
        itemToSave[@"creationDate"] = item.creationDate;
        itemToSave[@"listkey"] = item.listKey;
        
        if(item.segmentForItem.thestringid == nil)
            itemToSave[@"segmentid"] = @"";
        else
            itemToSave[@"segmentid"] = item.segmentForItem.thestringid;
        
        if(item.segmentForItem.segment == nil)
            itemToSave[@"segmentname"] = @"";
        else
            itemToSave[@"segmentname"] = item.segmentForItem.segment;
        
        if(item.endDate == nil)
            itemToSave[@"enddate"] = @"";
        else
            itemToSave[@"enddate"] = item.endDate;
        
        if(item.alertSelection== nil)
            itemToSave[@"alertselection"] = @"";
        else
            itemToSave[@"alertselection"] = item.alertSelection;
        
        if(item.repeatSelection == nil)
            itemToSave[@"repeatselection"] = @"";
        else
            itemToSave[@"repeatselection"] = item.repeatSelection;
        
        
        if(item.actualEndDate == nil)
            NSLog(@"%@ has nil actualEndDate", item.itemName);
        else
            itemToSave[@"actualEndDate"] = item.actualEndDate;
        
        
        [itemToSave saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
            if (succeeded){
                NSLog(@"List with key %@ and with item %@ saved to the cloud", key, item);
            }
            else{
                NSLog(@"Error saving list with key %@ and item %@: %@", key, item, error.description);
            }
        }];
    
    }

    
}



+(ToDoItem *)createToDoItem:(PFObject*)item{

    ToDoItem *toDoItem = [[ToDoItem alloc]init];
    
    toDoItem.itemid = item[@"itemid"];
    toDoItem.itemName = item[@"itemname"];
    toDoItem.completed = [item[@"completed"] boolValue];
    toDoItem.creationDate = item[@"creationDate"];
    toDoItem.listKey = item[@"listkey"];
    toDoItem.segmentForItem.thestringid = item[@"segmentid"];
    toDoItem.segmentForItem.segment = item[@"segmentname"];
    toDoItem.endDate = item[@"enddate"];
    toDoItem.alertSelection = item[@"alertselection"];
    toDoItem.repeatSelection = item[@"repeatselection"];
    
    if (item[@"actualEndDate"]){
        toDoItem.actualEndDate = item[@"actualEndDate"];
    }
    
    return toDoItem;
    
}

@end
