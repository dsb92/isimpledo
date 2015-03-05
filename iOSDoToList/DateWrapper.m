//
//  DateWrapper.m
//  iOSDoToList
//
//  Created by David Buhauer on 01/03/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "DateWrapper.h"

@implementation DateWrapper

+(NSString*)getCurrentDate{
    // get current date/time value
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    return currentTime;
}

+(NSString*)wrapDate:(NSString*)date{
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

+(NSDate*)convertToDate:(NSString*)date{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    
    return [df dateFromString:date];
}

@end
