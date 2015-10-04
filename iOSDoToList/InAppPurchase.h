//
//  InAppPurchase.h
//  SimpleDo
//
//  Created by David Buhauer on 04/10/2015.
//  Copyright © 2015 David Buhauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface InAppPurchase : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic) NSMutableArray *list;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property BOOL canMakePayments;

-(void) startIAPICheck;
-(void) buyProduct;
-(void) buyTransaction:(NSString*)prodID;
-(void) purchaseCloud;
-(void) restorePurchases;
-(void) enableCloud;

@end
