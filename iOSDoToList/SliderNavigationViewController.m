//
//  SliderNavigationViewController.m
//  SimpleDo
//
//  Created by David Buhauer on 24/06/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "SliderNavigationViewController.h"
#import "SWRevealViewController.h"
#import "InAppPurchase.h"

@interface SliderNavigationViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *bundleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *linkButton;

@property (strong, nonatomic) InAppPurchase *IAP;

@end

@implementation SliderNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.IAP = [[InAppPurchase alloc]init];
    [self.IAP startIAPICheck];
    
    // Do any additional setup after loading the view.
    self.iconImageView.layer.cornerRadius = 30;
    self.iconImageView.clipsToBounds = YES;
    
    //border
    //[self.iconImageView.layer setBorderColor:[UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0].CGColor];
    //[self.iconImageView.layer setBorderWidth:1.5f];
    
    // bundlename, version, build.
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
    
    self.bundleNameLabel.text = bundleName;
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@ (%@)", version, build];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Buy product


- (IBAction)StoreButtonTapped:(id)sender {
    
    
 
    UIAlertController * alert =   [UIAlertController
                                  alertControllerWithTitle:@"Store"
                                  message:@"Sync your to-do-items across all devices"
                                  preferredStyle:UIAlertControllerStyleAlert];


    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       NSLog(@"Cancel");
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];

    for (SKProduct *product in self.IAP.list){
        
        // Product title
        NSString *title = product.localizedTitle;
        
        // Format the price to local currency price
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        formatter.locale = product.priceLocale;
        
        // The localized price
        NSString *price = [formatter stringFromNumber:product.price];
        
        NSString *titleString = [NSString stringWithFormat:@"%@ \t %@", title, price];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:titleString style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       //Do Some action here
                                                       NSLog(@"Buying cloud...");
                                                       [self.IAP purchaseCloud];
                                                       
                                                   }];
        
        [alert addAction:ok];
        
        
        }
    
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];

    
}

- (IBAction)linkButtonTapped:(id)sender {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://dabdeveloper.wix.com/isimpledo"]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Do generel thing to show the next view controller
    if ([segue isKindOfClass:[SWRevealViewControllerSegue class]]) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc){
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers:@[dvc] animated:NO];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
    }
}


@end
