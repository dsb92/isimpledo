//
//  ToDoItem.h
//  iOSDoToList
//
//  Created by David Buhauer on 17/01/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SegmentForToDoItem.h"

@interface ToDoItem : NSObject

@property NSString* itemid;
@property NSString *itemName;
@property BOOL completed;
@property NSString *creationDate;
@property NSString *endDate;
@property NSDate *actualEndDate;
@property NSString *alertSelection;
@property NSString *repeatSelection;
@property NSString *listKey;

@property SegmentForToDoItem* segmentForItem;

+(NSDate*) getAlertDate: (ToDoItem*) item;
+(NSDate*) updateAlertDate:(ToDoItem*)item;
+(NSCalendarUnit) getRepeat:(ToDoItem*) item;
+(void) updateSegmentForItem:(ToDoItem*) item segment:(NSNumber*)segment;
@end
