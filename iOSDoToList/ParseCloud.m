//
//  ParseCloud.m
//  SimpleDo
//
//  Created by David Buhauer on 04/10/2015.
//  Copyright © 2015 David Buhauer. All rights reserved.
//

#import "ParseCloud.h"

@interface ParseCloud ()

@property PFObject *myList;

@end

@implementation ParseCloud



+(void)getUserList:(void(^)(PFObject *))callback{
    // Get the user
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser){
        PFQuery *query = [PFQuery queryWithClassName:@"Lists"];
        [query whereKey:@"username" equalTo:currentUser.username];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            // No errors means user has a list stored on the cloud
            if (error == nil){
                callback((PFObject*)object);
            }
            else{
                callback(nil);
            }
        }];
    }
}

+(void)saveToCloud:(NSMutableDictionary*)customListDictionary{
    
    // Get the user
    PFUser *currentUser = [PFUser currentUser];
    
    // Check if not null
    if (currentUser){
        NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc]init];
        NSMutableArray *myArray = [[NSMutableArray alloc]init];
        
        // Get the keys
        NSArray * sortedKeys = [[customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
        
        // Foreach key in the dictionary (Grocery etc)
        for(id key in sortedKeys){
            
            // Array with serialized ToDoItems objects
            NSMutableArray *jsonObjects = [[NSMutableArray alloc]init];
            
            // Return to do list for each key (Grocery, school, private etc.)
            id items = [customListDictionary objectForKey:key];
            
            NSError *error = nil;
            NSData *json;
            
            for(ToDoItem *item in items){
                id dic = [self dictionaryFromToDoItem:item];
                
                if ([NSJSONSerialization isValidJSONObject:dic]){
                    // Serialize the dictionary
                    json = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
                    
                    // If no errors, let's view the JSON
                    if (json != nil && error == nil)
                    {
                        NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
                        
                        [jsonObjects addObject:jsonString];
                        
                        NSLog(@"JSON: %@", jsonString);
                    }
                }
            }
            
            if ([items count] > 0) {
                [myDictionary setObject:jsonObjects forKey:key];
            }
            
            jsonObjects = nil;
            
        }
        
        [myArray addObject:myDictionary];
        
        [self getUserList:^(PFObject* object) {
            if (object != nil){
                object[@"lists"] = myArray;
                object[@"username"] = [PFUser currentUser].username;
                
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        NSLog(@"LIST UPDATED!");
                    }
                }];
            }
            else{
                PFObject *myList = [PFObject objectWithClassName:@"Lists"];
                myList[@"lists"] = myArray;
                myList[@"username"] = [PFUser currentUser].username;
                [myList saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        NSLog(@"NEW LIST SAVED!");
                    }
                }];
            }
        }];
    }
}

+(void)loadFromCloud: (void(^)(NSMutableArray *))callback{
    
    [self getUserList:^(PFObject *object) {
        callback(object[@"lists"]);
    }];
    
}


+(NSDictionary *)dictionaryFromToDoItem:(ToDoItem*)item{
    return [NSDictionary dictionaryWithObjectsAndKeys:item.itemid, @"itemid",
     item.itemName, @"itemName",
     [NSNumber numberWithBool:item.completed], @"completed",
     item.creationDate, @"creationDate",
     item.listKey, @"listKey",
     item.segmentForItem.thestringid, @"thestringid",
     item.segmentForItem.segment, @"segment",
     item.endDate, @"endDate",
     item.alertSelection, @"alertSelection",
     item.repeatSelection, @"repeatSelection",
     item.actualEndDate, @"actualEndDate",
     
     nil];
}

@end
