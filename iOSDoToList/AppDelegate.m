//
//  AppDelegate.m
//  iOSDoToList
//
//  Created by David Buhauer on 16/01/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    // If the user is currently using this app.
    if (state == UIApplicationStateActive) {
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        */
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Reminder"
                                      message:notification.alertBody
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                   }];
        
        [alert addAction:ok];
        #define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]
        [ROOTVIEW presentViewController:alert animated:YES completion:^{}];

    }
    // Request to reload table view data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    
    // Clear app icon badge number.
    //application.applicationIconBadgeNumber=0;
    NSLog(@"%ld", (long)application.applicationIconBadgeNumber);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Color of app
    self.window.tintColor = [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0];
    
    // Handle launching from a local notification
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        //application.applicationIconBadgeNumber=0;
    }
    
    return YES;
}

/*
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}
 */

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // Save an "Use a moment to plan your day" notificaiton that fires after 4 days.
    NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
    [dateComponents setDay:4];
    
    NSDate *alert = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    
    // Schedule the notification
    UILocalNotification *localNotification = [[UILocalNotification alloc]init];
    localNotification.fireDate = alert;
    localNotification.repeatInterval = NSCalendarUnitWeekday;
    localNotification.alertBody = @"Use a moment to plan your day";
    localNotification.alertAction = @"Lets go";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.timeZone = [NSTimeZone localTimeZone];
    //NSUInteger nextBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count] + 1;
    //localNotification.applicationIconBadgeNumber = nextBadgeNumber;

    // Use a dictionary to keep track on each notification attacted to each local system notification.
    NSDictionary *info = [NSDictionary dictionaryWithObject:@"Use a moment" forKey:@"systemLocal"];
    localNotification.userInfo = info;
    NSLog(@"SYSTEM Notification userInfo gets key: %@",[info objectForKey:@"systemLocal"]);
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    NSLog(@"SYSTEM Notification created");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //application.applicationIconBadgeNumber = 0;
    
    NSLog(@"%ld", (long)application.applicationIconBadgeNumber);
    NSLog(@"application became active");
    
    // Let user decide whether he/she wishes to have local notifications with sound and badge number etc..
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    // Cancel System notification.
    for(UILocalNotification *localN in [[UIApplication sharedApplication]scheduledLocalNotifications]){
        if([[localN.userInfo objectForKey:@"systemLocal"] isEqualToString:@"Use a moment"]){
            [[UIApplication sharedApplication] cancelLocalNotification:localN];
            NSLog(@"SYSTEM Notification canceled");
            return;
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
