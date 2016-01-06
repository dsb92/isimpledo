//
//  SignUpViewController.m
//  SimpleDo
//
//  Created by David Buhauer on 17/10/2015.
//  Copyright © 2015 David Buhauer. All rights reserved.
//

#import "SignUpViewController.h"
#import "SWRevealViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Background
    [self.signUpView setBackgroundColor:[UIColor whiteColor]];
    
    // Logo
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"startup_logo"]]];
    
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    
    [[self.signUpView signUpButton] setTitleColor:[UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0] forState:UIControlStateNormal];
    
    // Signup button
    [[self.signUpView signUpButton] setBackgroundColor:[UIColor lightGrayColor]];
}

-(void)viewDidLayoutSubviews{
    self.signUpView.logo.contentMode = UIViewContentModeScaleAspectFill;
    
    // Login button
    self.signUpView.signUpButton.backgroundColor = [UIColor whiteColor];
}

/* SIGN UP DELEGATES */

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    //[self dismissModalViewControllerAnimated:YES]; // Dismiss the PFSignUpViewController
    
    SWRevealViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainViewController"];
    
    [self presentViewController:viewController animated:YES completion:NULL];
    
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...%@", error.description);
    
    [[[UIAlertView alloc] initWithTitle:@"Sign up failed"
                                message:@"Please try again..."
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
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
