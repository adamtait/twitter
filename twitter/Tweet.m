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

    - (void)generateCreatedFromDateString:(NSString *)createdAtDateString;

@end

@implementation Tweet


#pragma public static methods

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *params in array) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:params];
        [tweet generateCreatedFromDateString:tweet.data[@"created_at"]];
        [tweets addObject:tweet];
        
        NSLog(@"got a tweet / %@ /", tweet);
    }
    return tweets;
}



#pragma public instance methods

- (NSString *)text {
    return [self.data valueForKey:@"text"];
}

- (NSString *)username {
    return [[self userDict] valueForKey:@"name"];
}

- (NSString *)userhandle {
    return [NSString stringWithFormat:@"@%@", [[self userDict] valueForKeyPath:@"screen_name"]];
}

- (NSString *)profileImageURL {
    return [[self userDict] valueForKey:@"profile_image_url"];
}

- (void)generateCreatedFromDateString:(NSString *)createdAtDateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    NSDate *tweetDate = [dateFormatter dateFromString:createdAtDateString];
    int timeInterval = (int)([tweetDate timeIntervalSinceNow] * -1);
    NSString *timeIntervalString;
    
    if (timeInterval < 60){
        timeIntervalString = [NSString stringWithFormat:@"%ds", timeInterval];
    } else if (timeInterval < (60 * 60)) {
        timeIntervalString = [NSString stringWithFormat:@"%dm", (timeInterval/60)];
    } else if (timeInterval < (60 * 60 * 24)) {
        timeIntervalString = [NSString stringWithFormat:@"%dh", (timeInterval/60)/60];
    } else {
        NSDateFormatter *shortDateFormatter = [[NSDateFormatter alloc] init];
        [shortDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [shortDateFormatter setDateStyle:NSDateFormatterShortStyle];
        timeIntervalString = [shortDateFormatter stringFromDate:tweetDate];
    }
    
    self.createdAt = timeIntervalString;
}



#pragma private methods

- (NSDictionary *)userDict
{
    return [self.data valueForKey:@"user"];
}

@end
