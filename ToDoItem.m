//
//  ToDoItem.m
//  iOSDoToList
//
//  Created by David Buhauer on 17/01/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "ToDoItem.h"
#import "CustomListManager.h"

@implementation ToDoItem

+(NSDate*) getAlertDate: (ToDoItem*) item{
    NSString *alertSelection = item.alertSelection;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSDate *reminderDate = [dateFormatter dateFromString:item.endDate];
    
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

+(NSDate*) updateAlertDate:(ToDoItem*)item{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSDate *reminderDate = [dateFormatter dateFromString:item.endDate];
    
    
    if([item.repeatSelection length] == 0 || [item.repeatSelection isEqualToString:@"Never"]) return reminderDate;
    
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

+(NSCalendarUnit) getRepeat:(ToDoItem*) item{
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

+(void) updateSegmentForItem:(ToDoItem*) item segment:(NSNumber*)segment{
    NSString *segmentStr = [NSString stringWithFormat:@"segment %@", segment];
    if(item.segmentForItem == nil)
    {
        SegmentForToDoItem *segmentItem = [[SegmentForToDoItem alloc]init];
        segmentItem.thestringid = item.itemid;
        segmentItem.segment = segmentStr;
        
        item.segmentForItem = segmentItem;
    }

    if(item.endDate == nil && item.actualEndDate == nil)
    {
        if([item.segmentForItem.segment isEqualToString:@"segment 1"])
        {
            item.actualEndDate = [NSDate date];
        }
        
        else if([item.segmentForItem.segment isEqualToString:@"segment 2"])
        {
            NSDateComponents *components = [[NSDateComponents alloc]init];
            
            [components setDay:1];
            
            NSDate *tomorrow = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0];
            item.actualEndDate = tomorrow;
        }
    }
}


+(void)saveToLocal{
    
    CustomListManager *sharedManager = [CustomListManager sharedManager];
    
    NSString *filePath= [self pathOfFile];
    
    NSArray * sortedKeys = [[sharedManager.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    NSMutableArray *listArray = [[NSMutableArray alloc]init];
    
    for(id key in sortedKeys){
        NSMutableArray *mainArray = [[NSMutableArray alloc]init];
        
        // Add key as first item (Grocery etc..)
        [mainArray addObject:key];
        // Return to do list for each key (Grocery, school, private etc.)
        id list = [sharedManager.customListDictionary objectForKey:key];
        
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

+(void)loadFromLocal{
    CustomListManager *sharedManager = [CustomListManager sharedManager];
    
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
        
        
        [sharedManager.customListDictionary setValue:newList forKey:key];
        newList = [[NSMutableArray alloc]init];
    }
    
}


+(NSString *)pathOfFile{
    // Returns an array of directories
    // App's document is the first element in this array
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path =[[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"todolist.plist"]];
    
    return path;
}


@synthesize actualEndDate;
@end
