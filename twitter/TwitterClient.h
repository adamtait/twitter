//
//  TwitterClient.h
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "AFOAuth1Client.h"

@interface TwitterClient : AFOAuth1Client

+ (TwitterClient *)instance;
+ (void (^)(AFHTTPRequestOperation *operation, id response))emptySuccessBlock;
+ (void (^)(AFHTTPRequestOperation *operation, NSError *error))networkFailureBlock;

// Users API

- (void)authorizeWithCallbackUrl:(NSURL *)callbackUrl success:(void (^)(AFOAuth1Token *accessToken, id responseObject))success
                         failure:(void (^)(NSError *error))failure;

- (void)currentUserWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id response))success;

// Statuses API

- (void)homeTimelineWithCount:(int)count
                      sinceId:(NSString *)sinceId
                        maxId:(NSString *)maxId
                      success:(void (^)(AFHTTPRequestOperation *operation, id response))success;

- (void)homeTimelineWithCount:(int)count
                      sinceId:(NSString *)sinceId
                        maxId:(NSString *)maxId
                      success:(void (^)(AFHTTPRequestOperation *operation, id response))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)createRetweet:(NSString *)tweetId callback:(void (^)(NSDictionary *tweetWithRetweet))callback;
- (void)deleteRetweet:(NSString *)tweetId;
- (void)createFavorite:(NSString *)tweetId;
- (void)deleteFavorite:(NSString *)tweetId;
- (void)updateStatusWithString:(NSString *)status;

@end
