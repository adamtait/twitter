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

    // public static methods
    + (NSMutableArray *)tweetsWithArray:(NSArray *)array;

    // public properties
    @property (nonatomic, strong, readonly) NSString *text;
    @property (nonatomic, strong, readonly) NSString *username;
    @property (nonatomic, strong, readonly) NSString *userhandle;
    @property (nonatomic, strong, readonly) NSString *profileImageURL;
    @property (nonatomic, strong) NSString *createdAt;
    @property (nonatomic, strong, readonly) NSString *idStr;
    @property BOOL favorited;
    @property BOOL retweeted;
    @property (nonatomic, strong, readonly) NSString *retweeterUserhandle;
    @property (nonatomic, strong, readonly) NSString *favoriteCount;
    @property (nonatomic, strong, readonly) NSString *retweetCount;
    @property BOOL retweetedByMe;

    // public methods
    - (id)initWithString:(NSString *)status;
    - (BOOL)createRetweet;
    - (BOOL)deleteRetweet;
    - (BOOL)toggleFavorite;


@end
