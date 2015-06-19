//
//  ToDoItem.m
//  iOSDoToList
//
//  Created by David Buhauer on 17/01/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "ToDoItem.h"

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


@synthesize actualEndDate;
@end
