//
//  DateWrapper.h
//  iOSDoToList
//
//  Created by David Buhauer on 01/03/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateWrapper : NSObject

+(NSString*)getCurrentDate;
+(NSString*)wrapDate:(NSString*)date;
+(NSDate*)convertToDate:(NSString*)date;

@end
