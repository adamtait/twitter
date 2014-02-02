//
//  User.h
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestObject.h"

extern NSString *const UserDidLoginNotification;
extern NSString *const UserDidLogoutNotification;

@interface User : RestObject

    // public static class methods
    + (User *)currentUser;
    + (void)setCurrentUser:(User *)currentUser;

    // public instance methods
    @property (nonatomic, strong, readonly) NSString *username;
    @property (nonatomic, strong, readonly) NSString *userhandle;
    @property (nonatomic, strong, readonly) NSString *profileImageURL;

@end