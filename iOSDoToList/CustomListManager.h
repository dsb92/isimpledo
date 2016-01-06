//
//  CustomListManager.h
//  SimpleDo
//
//  Created by David Buhauer on 06/01/2016.
//  Copyright © 2016 David Buhauer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomListManager : NSObject{
    NSMutableDictionary *customListDictionary;
}

@property (nonatomic, retain) NSMutableDictionary *customListDictionary;

+(id)sharedManager;

@end
