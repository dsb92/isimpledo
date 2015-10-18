//
//  LoginViewController.m
//  SimpleDo
//
//  Created by David Buhauer on 17/10/2015.
//  Copyright © 2015 David Buhauer. All rights reserved.
//

#import "LoginViewController.h"
#import "SWRevealViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Background
    [self.logInView setBackgroundColor:[UIColor whiteColor]];
    
    // Logo
    //[self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"startup_logo"]]];
    
    // Login button
    [[self.logInView logInButton] setBackgroundColor:[UIColor whiteColor]];
    //[[self.logInView logInButton] setTitleColor:[UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0] forState:UIControlStateNormal];
    
    // Signup button
    [[self.logInView signUpButton] setBackgroundColor:[UIColor lightGrayColor]];
}

-(void)viewDidLayoutSubviews{
    
    
    
}


/* LOGIN DELEGATES */

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    
    PFUser *currentUser = [PFUser currentUser];
    
    NSLog(@"User %@ logged in", currentUser.username);
    
    SWRevealViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainViewController"];
    
    [self presentViewController:viewController animated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...%@", error.description);
    
    [[[UIAlertView alloc] initWithTitle:@"Login failed"
                                message:@"Please try again..."
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    //[self.navigationController popViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
