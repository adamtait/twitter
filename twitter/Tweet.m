//
//  Tweet.m
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "Tweet.h"

@interface Tweet ()

    // private methods
    - (NSDictionary *)userDict;

@end

@implementation Tweet


#pragma public static methods

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *params in array) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:params];
        [tweets addObject:tweet];
        NSLog(@"got a tweet / %@ /", tweet);
    }
    return tweets;
}



#pragma public instance methods

- (NSString *)text {
    return [self.data valueForKeyPath:@"text"];
}

- (NSString *)username {
    return [[self userDict] valueForKeyPath:@"name"];
}

- (NSString *)userhandle {
    return [NSString stringWithFormat:@"@%@", [[self userDict] valueForKeyPath:@"screen_name"]];
}




#pragma private methods

- (NSDictionary *)userDict
{
    return [self.data valueForKeyPath:@"user"];
}

@end
