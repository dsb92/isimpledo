//
//  SingletonDictionary.h
//  SimpleDo
//
//  Created by David Buhauer on 17/06/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingletonDictionary : NSObject{
    NSMutableDictionary *customDictionary;
}

@property (nonatomic,retain) NSMutableDictionary *customDictionary;

+(id) sharedDictionary;

@end
