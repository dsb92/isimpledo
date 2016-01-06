//
//  CustomListManager.m
//  SimpleDo
//
//  Created by David Buhauer on 06/01/2016.
//  Copyright © 2016 David Buhauer. All rights reserved.
//

#import "CustomListManager.h"

@implementation CustomListManager

@synthesize customListDictionary;

#pragma mark Singleton Methods

+(id)sharedManager {
    static CustomListManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        customListDictionary = [[NSMutableDictionary alloc]init];
    }
    return self;
}

@end
