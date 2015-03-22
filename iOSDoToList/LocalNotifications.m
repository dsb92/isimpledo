//
//  LocalNotifications.m
//  iOSDoToList
//
//  Created by David Buhauer on 22/03/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "LocalNotifications.h"

@implementation LocalNotifications

+(void) setLocalNotification:(ToDoItem*) item isOn:(BOOL)isOn{
    if(!isOn) return;
    
    if([item.alertSelection length] == 0 || [item.alertSelection isEqualToString:@"None"]) return;
    
    // Schedule the notification
    UILocalNotification *localNotification = [[UILocalNotification alloc]init];
    localNotification.fireDate = [ToDoItem getAlertDate:item];
    localNotification.alertBody = item.itemName;
    localNotification.alertAction = @"Show me the item";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.timeZone = [NSTimeZone localTimeZone];
    NSUInteger nextBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count] + 1;
    localNotification.applicationIconBadgeNumber = nextBadgeNumber;
    
    if(![item.repeatSelection isEqualToString:@"Never"])
        localNotification.repeatInterval = [ToDoItem getRepeat:item];
    
    // Use a dictionary to keep track on each notification attacted to each to-do item.
    NSDictionary *info = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", item.itemid] forKey:@"itemid"];
    localNotification.userInfo = info;
    NSLog(@"Notification userInfo gets item id : %@",[info objectForKey:@"itemid"]);
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound
                                                                                                              categories:nil]];
    }
    
    NSLog(@"Notification created");
}


// In order to edit a local notification u need to cancel it/delete it and then make a new one (unfortunately)
+(void) editLocalNotification:(ToDoItem*)item isOn:(BOOL)isOn{
    
    // Cancel
    [self cancelLocalNotification:item];
    
    // Create a new
    [self setLocalNotification:item isOn:YES];
}


+(void) cancelLocalNotification:(ToDoItem*)item{
    for(UILocalNotification *localN in [[UIApplication sharedApplication]scheduledLocalNotifications]){
        if([[localN.userInfo objectForKey:@"itemid"] isEqualToString:item.itemid]){
            [[UIApplication sharedApplication] cancelLocalNotification:localN];
            NSLog(@"Notification canceled");
            return;
        }
    }
}

@end
