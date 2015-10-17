//
//  ParseCloud.h
//  SimpleDo
//
//  Created by David Buhauer on 04/10/2015.
//  Copyright © 2015 David Buhauer. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>
#import "ToDoItem.h"

@interface ParseCloud : NSObject

+(void)saveToCloud:(NSMutableDictionary*)customListDictionary;
+(void)saveCloud:(NSMutableDictionary*)customListDictionary;
+(void)loadCloud;

@end
