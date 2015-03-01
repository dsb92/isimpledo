//
//  DateWrapper.m
//  iOSDoToList
//
//  Created by David Buhauer on 01/03/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "DateWrapper.h"

@implementation DateWrapper

+(NSString *)wrapDate:(NSString*)date{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *wrapperStr = [[NSString alloc]initWithFormat:@"%@", date];
    NSDate *dateWrapper = [df dateFromString:wrapperStr];
    
    NSDateFormatter *dfWrapper = [[NSDateFormatter alloc] init];
    [dfWrapper setDateStyle:NSDateFormatterFullStyle];
    [dfWrapper setTimeStyle:NSDateFormatterShortStyle];
    [dfWrapper setDoesRelativeDateFormatting:YES];
    
    return [dfWrapper stringFromDate:dateWrapper];
}

@end
