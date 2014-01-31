//
//  Tweet.h
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestObject.h"

@interface Tweet : RestObject

    @property (nonatomic, strong, readonly) NSString *text;

    + (NSMutableArray *)tweetsWithArray:(NSArray *)array;

@end
