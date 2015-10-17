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
        
        // Do stuff with the user
        NSLog(@"Anonymous user %@ is logged in", currentUser);
    
        // Check if there is an existing Lists on the cloud
        PFQuery *query = [PFQuery queryWithClassName:@"Lists"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error){
            
            // If no errors finding existing lists
            if (error == nil){
                
                // If there are lists
                if (objects != nil && objects.count != 0){
                    
                    for (id obj in objects){
                        
                        [self saveExistingList:obj dictionary:customListDictionary];
                        
                    }
                    
                    
                }
                else{
                    
                    NSLog(@"No existing lists in cloud, creating new list to store");
                    [self saveNewList:customListDictionary];
                    
                    
                }
                
            }
            else{
                
                NSLog(@"Error finding existing lists : %@", error.description);
                
                
            }
            
            
            
        }];

    }
}

+(void)saveExistingList:(PFObject*)list dictionary:(NSMutableDictionary*)dictionary{
    
    PFUser *currentUser = [PFUser currentUser];
    
    // Get the keys
    NSArray * sortedKeys = [[dictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    for(id key in sortedKeys){
        
        list[@"username"] = currentUser.username;
        list[@"listkey"] = key;
        
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


+(void)saveCloud:(NSMutableDictionary*)customListDictionary{
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        
        // do stuff with the user
        NSLog(@"Anonymous user %@ is logged in", currentUser);
        
        NSArray * sortedKeys = [[customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
        
        for(id key in sortedKeys){
            
            // Create the list
            PFQuery *query = [PFQuery queryWithClassName:@"Lists"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                
                if (error == nil){
                    
                    if (objects != nil && objects.count != 0){
                        
                        for (id obj in objects){
                            
                            obj[@"username"] = currentUser.username;
                            obj[@"listkey"] = key;
                            
                            // Return to do list for each key (Grocery, school, private etc.)
                            id list = [customListDictionary objectForKey:key];
                            
                            for(ToDoItem *item in list){
                                
                                // Create an item
                                /* Non-nullable values */
                                PFObject *itemToSave = [PFObject objectWithClassName:@"Items"];
                                
                                itemToSave[@"list"] = obj;
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
                                        NSLog(@"ParseCloud: Objects saved");
                                    }
                                    else{
                                        NSLog(@"ERROR ParseCloud: Objects saving failed with error: %@", error.description);
                                    }
                                }];

                                
                                
                            }

                            
                        }
                        
                        
                    }
                    else {
                        
                        PFObject *obj = [PFObject objectWithClassName:@"Lists"];
                        
                        obj[@"username"] = currentUser.username;
                        obj[@"listkey"] = key;
                        
                        // Return to do list for each key (Grocery, school, private etc.)
                        id list = [customListDictionary objectForKey:key];
                        
                        for(ToDoItem *item in list){
                            
                            // Create an item
                            /* Non-nullable values */
                            PFObject *itemToSave = [PFObject objectWithClassName:@"Items"];
                            
                            [itemToSave deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                
                                itemToSave[@"list"] = obj;
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
                                        NSLog(@"ParseCloud: Objects saved");
                                    }
                                    else{
                                        NSLog(@"ERROR ParseCloud: Objects saving failed with error: %@", error.description);
                                    }
                                }];
                                
                            }];
                            
                            
                        }

                        
                    }
                    
                }
                
            }];
            
            
        }
        
        
    } else {
        // show the signup or login screen
    }

    
}

+(void)loadCloud{
    
    
    
}

@end
