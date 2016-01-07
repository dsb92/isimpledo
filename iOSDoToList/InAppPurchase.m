//
//  InAppPurchase.m
//  SimpleDo
//
//  Created by David Buhauer on 04/10/2015.
//  Copyright © 2015 David Buhauer. All rights reserved.
//

#import "InAppPurchase.h"

@implementation InAppPurchase
static NSString *enable_cloud_string=@"isimpledo.iap.enablecloud";
static NSString *remove_ads_strings=@"isimpledo.iap.removeads";

-(id)init{
    
    self.list = [[NSMutableArray alloc]init];
    self.product = [[SKProduct alloc]init];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    return self;
}

-(void) startIAPICheck{
    
    if ([SKPaymentQueue canMakePayments]) {
        
        NSLog(@"In-App Purchase: IAP is enabled...loading");
        NSSet *prodID = [[NSSet alloc] initWithObjects:enable_cloud_string, remove_ads_strings, nil];
        SKProductsRequest *request = [[SKProductsRequest alloc]initWithProductIdentifiers:prodID];
        request.delegate = self;
        
        if (self.list.count == 0){
            [request start];
        }
        else{
            
        }
        
        self.canMakePayments = YES;
        
    }
    else {
        
        NSLog(@"In-App Purchase: please enable IAPS");
        self.canMakePayments = NO;
        
    }
    
}

-(NSString*)getIAPCloudString{
    return enable_cloud_string;
}

-(NSString*)getIAPRemoveAdsString{
    return remove_ads_strings;
}

/* IN-APP PURCHASE FUNCTIONS TO BE RUN */


-(void) buyProduct{
    
    NSLog(@"In-App Purchase: buy %@", self.product.productIdentifier);
    
    SKPayment *payment = [SKPayment paymentWithProduct:self.product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
}

#pragma mark -
#pragma mark SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"In-AppPurchase: product request");
    
    NSArray *products = response.products;
    
    for (SKProduct *product in products)
    {
        NSLog(@"In-AppPurchase: product added");
        NSLog(@"%@", product.productIdentifier);
        NSLog(@"%@", product.localizedTitle);
        NSLog(@"%@", product.localizedDescription);
        
        [self.list addObject:product];
    }
    
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"In-AppPurchase: add payment");
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                
                [self buyTransaction:self.product.productIdentifier];
                
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"Transaction Failed");
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver

-(void) paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    
    NSLog(@"In-AppPurchase: remove trans");
    
}

-(void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    
    NSLog(@"In-AppPurchase: transactions restored");
    
    // Bug fix so transaction queue is no more than 2
    int purchases = 2;
    int transactionCount = 0;
    
    for (SKPaymentTransaction *transaction in queue.transactions) {
        
        NSString *prodID = transaction.payment.productIdentifier;
        
        if ([prodID isEqualToString:enable_cloud_string]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cloud purchase restored"
                                                            message:nil
                                                           delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            [self buyTransaction:prodID];
            ++transactionCount;
        }
        else if ([prodID isEqualToString:remove_ads_strings]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remove Ads purchase restored"
                                                            message:nil
                                                           delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            [self buyTransaction:prodID];
            ++transactionCount;
        }
        
        if (transactionCount == purchases)
            break;
        
    }
    
}

// The buy transaction being processed
-(void) buyTransaction:(NSString*)prodID{
    
    if ([prodID isEqualToString:enable_cloud_string]){
        
        NSLog(@"In-AppPurchase: enable cloud");
        [self enableCloud];
        
    }
    else if ([prodID isEqualToString:remove_ads_strings]){
        NSLog(@"In-AppPurchase: remove ads");
        [self removeAds];
    }
    
}

/* PURCHASE PRODUCT */

-(void) purchaseCloud{
    
    for (SKProduct *product in self.list){
        
        NSString *prodID = (NSString*)product.productIdentifier;
        if ([prodID isEqualToString:enable_cloud_string]){
            self.product = product;
            [self buyProduct];
            break;
        }
        
    }
    
}

-(void) purchaseRemoveAds{
    
    for (SKProduct *product in self.list){
        
        NSString *prodID = (NSString*)product.productIdentifier;
        if ([prodID isEqualToString:remove_ads_strings]){
            self.product = product;
            [self buyProduct];
            break;
        }
        
    }
    
}

-(void) restorePurchases{
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue]restoreCompletedTransactions];
    
}

-(void) enableCloud{
    
    NSLog(@"In-AppPurchase: enabling cloud to your account!");
    
    [self.userDefaults setBool:YES forKey:@"cloudenabled"];
    
}

-(void) removeAds{
    
    NSLog(@"In-AppPurchase: removing ads from your account!");
    
    [self.userDefaults setBool:YES forKey:@"removeAds"];
}

@end
