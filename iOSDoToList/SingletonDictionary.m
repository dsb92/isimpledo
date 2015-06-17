//
//  SingletonDictionary.m
//  SimpleDo
//
//  Created by David Buhauer on 17/06/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "SingletonDictionary.h"

@implementation SingletonDictionary

@synthesize customDictionary;

+(id) sharedDictionary {
    static SingletonDictionary *sharedMySingleton = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMySingleton = [[self alloc] init];
    });
    return sharedMySingleton;
}

- (id)init {
    if (self = [super init]) {
        // Load default list
        NSMutableArray *newList = [[NSMutableArray alloc]init];
        customDictionary = [[NSMutableDictionary alloc]init];
        [customDictionary setValue:newList forKey:@"Grocery"];
        [customDictionary setValue:newList forKey:@"School"];
        [customDictionary setValue:newList forKey:@"Private"];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
