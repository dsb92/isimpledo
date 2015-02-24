//
//  ToDoItem.h
//  iOSDoToList
//
//  Created by David Buhauer on 17/01/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoItem : NSObject

@property NSString *itemName;
@property BOOL completed;
@property NSString *creationDate;
@property NSString *endDate;
@property NSString *alertSelection;
@property NSString *repeatSelection;

@end
