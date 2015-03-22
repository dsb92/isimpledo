//
//  LocalNotifications.h
//  iOSDoToList
//
//  Created by David Buhauer on 22/03/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ToDoItem.h"

@interface LocalNotifications : NSObject

+(void) setLocalNotification:(ToDoItem*) item isOn:(BOOL)isOn;
+(void) editLocalNotification:(ToDoItem*)item isOn:(BOOL)isOn;
+(void) cancelLocalNotification:(ToDoItem*)item;

@end
