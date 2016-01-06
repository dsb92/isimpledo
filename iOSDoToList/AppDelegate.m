//
//  AppDelegate.m
//  iOSDoToList
//
//  Created by David Buhauer on 16/01/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "SWRevealViewController.h"
#import "ListsViewController.h"
#import "AppDelegate.h"
#import "CustomListManager.h"
#import "DateWrapper.h"
#import "ParseCloud.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface AppDelegate () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property LoginViewController *logInViewController;
@property SignUpViewController *signUpViewController;
@end

@implementation AppDelegate


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    // If the user is currently using this app.
    if (state == UIApplicationStateActive) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        /*
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Reminder"
                                      message:notification.alertBody
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                   }];
        
        [alert addAction:ok];
        ListsViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ListsViewController"];
        [viewController presentViewController:alert animated:YES completion:^{}];
         */

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
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        // app already launched
        NSLog(@"App already launched!");
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // This is the first launch ever
        NSLog(@"First time launch!");
        
        // Cancel any notifications.
        [[UIApplication sharedApplication]cancelAllLocalNotifications];
        NSLog(@"Canceled any existing notifications to this app");
        
    }
    
    PFUser *currentUser = [PFUser currentUser];
    
    // If user is cached (logged in)
    if (currentUser){
        
        SWRevealViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainViewController"];
        
        self.window.rootViewController = viewController;
        [self.window makeKeyAndVisible];
        
    }
    // Else show login view
    else{
        
        //LoginViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
        // Create the log in view controller
        self.logInViewController = [[LoginViewController alloc] init];
        [self.logInViewController setDelegate:self.logInViewController]; // Set ourselves as the delegate
        self.logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsFacebook | PFLogInFieldsTwitter;
        
        // Create the sign up view controller
        self.signUpViewController = [[SignUpViewController alloc] init];
        [self.signUpViewController setDelegate:self.signUpViewController]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [self.logInViewController setSignUpController:self.signUpViewController];
        
        self.window.rootViewController = self.logInViewController;
        [self.window makeKeyAndVisible];
    }
    
    
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"awhAw60IjDsROJ8gzuJ96YwzTnB6ydz07zhbyTtJ"
                  clientKey:@"CUx87vZCevfaxRRSmomkQVnH40oIZcGGquv4EyqR"];
    
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFUser enableAutomaticUser];
    
    PFACL *defaultACL = [PFACL ACL];
    
    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
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
    
    // Save to cloud AND local
    
    if ([ParseCloud cloudEnabled]){
        CustomListManager *sharedManager = [CustomListManager sharedManager];
        [ParseCloud saveToCloud:sharedManager.customListDictionary];
    }
    
    [ToDoItem saveToLocal];
    
    // Update notifications badgde
    [self updateNotificationBadge];
    
    // Create a local notification
    [self createIdleNotification];
    
}

-(void)createIdleNotification{
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

-(void)updateNotificationBadge{
    CustomListManager *sharedManager = [CustomListManager sharedManager];
    
    NSArray * sortedKeys = [[sharedManager.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    // How many items have exceeded the current date(if any reminder given)
    NSUInteger count = 0;
    // Foreach key in dictionary
    for(id key in sortedKeys) {
        NSMutableArray *list = [sharedManager.customListDictionary objectForKey:key];
        
        NSDate *currentDate = [DateWrapper convertToDate:[DateWrapper getCurrentDate]];
        
        for (ToDoItem *item in list) {
            if(!item.completed && ([item.alertSelection length] != 0 || ![item.alertSelection isEqualToString:@"None"])){
                NSDate *itemDueDate = [DateWrapper convertToDate:item.endDate];
                if(itemDueDate==nil)continue;
                
                if([currentDate compare:itemDueDate] == NSOrderedDescending || [currentDate compare:itemDueDate] == NSOrderedSame){
                    count++;
                }
            }
        }
        
        // clear the badge on the icon
        //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
        // The following code renumbers the badges of pending notifications (in case user deletes or changes some local notifications while the app was running). So the following code runs, when the user
        // gets out of the app.
        
        // first get a copy of all pending notifications (unfortunately you cannot 'modify' a pending notification)
        NSArray *pendingNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        
        // if there are any pending notifications -> adjust their badge number
        if (pendingNotifications.count != 0)
        {
            // clear all pending notifications
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
            // the for loop will 'restore' the pending notifications, but with corrected badge numbers
            // note : a more advanced method could 'sort' the notifications first !!!
            NSUInteger badgeNbr = 1;
            
            // LIFO order, the last notification created is the first that gets updated.
            for (UILocalNotification *notification in pendingNotifications)
            {
                // Dont schedule again for "old" fire dates (with repeatIntervals set)
                if([[NSDate date] compare:notification.fireDate] == NSOrderedDescending || [[NSDate date] compare:notification.fireDate] == NSOrderedSame) continue;
                
                // modify the badgeNumber
                notification.applicationIconBadgeNumber = badgeNbr+count;
                badgeNbr++;
                
                // schedule 'again'
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    
    //application.applicationIconBadgeNumber = 0;
    
    NSLog(@"Badge number: %ld", (long)application.applicationIconBadgeNumber);
    NSLog(@"Application became active");
    
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
    
    if ([ParseCloud cloudEnabled]){
        CustomListManager *sharedManager = [CustomListManager sharedManager];
        [ParseCloud saveToCloud:sharedManager.customListDictionary];
    }
    
    [ToDoItem saveToLocal];
}

#pragma mark Facebook SDK Integration

///////////////////////////////////////////////////////////
// Uncomment this method if you are using Facebook
///////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance]application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

@end
