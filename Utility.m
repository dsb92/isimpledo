//
//  Utility.m
//  iOSDoToList
//
//  Created by David Buhauer on 26/02/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "Utility.h"

@implementation Utility


+(NSString*)generateUniqID{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)
                      uuidStringRef];
    CFRelease(uuidStringRef);
    return uuid;
}

@end
