//
//  Tweet.m
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "Tweet.h"
#import "TwitterClient.h"
#import "User.h"

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
        tweet.favorited = [tweet.data[@"favorited"] boolValue];

        [tweets addObject:tweet];
        NSLog(@"got a tweet / %@ /", tweet);
    }
    return tweets;
}



#pragma public properties

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



#pragma public instance methods

- (id)initWithString:(NSString *)status
{
    NSMutableDictionary *tweetData = [[NSMutableDictionary alloc] init];
    [tweetData setValue:status forKey:@"text"];
    
    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];

    [userDictionary setValue:[User currentUser].username forKey:@"name"];
    NSString *userhandle = [[User currentUser].userhandle substringFromIndex:1];
    [userDictionary setValue:userhandle forKeyPath:@"screen_name"];
    [userDictionary setValue:[User currentUser].profileImageURL forKey:@"profile_image_url"];
    [tweetData setValue:userDictionary forKey:@"user"];
    
    self = [super initWithDictionary:tweetData];
    if (self) {
        self.createdAt = @"0s";
    }
    return self;
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

- (BOOL)createRetweet
{
    NSString *tweetId = self.data[@"id_str"];
    [[TwitterClient instance] createRetweet:tweetId];
    return YES;
}

- (BOOL)toggleFavorite
{
    NSString *tweetId = self.data[@"id_str"];
    if (_favorited) {
        [[TwitterClient instance] deleteFavorite:tweetId];
    } else {
        [[TwitterClient instance] createFavorite:tweetId];
    }
    
    // toggle the favorited boolean
    _favorited = !_favorited;
    return _favorited;
}


#pragma private methods

- (NSDictionary *)userDict
{
    return [self.data valueForKey:@"user"];
}

@end
