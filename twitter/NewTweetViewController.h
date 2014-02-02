//
//  NewTweetViewController.h
//  twitter
//
//  Created by Adam Tait on 2/2/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface NewTweetViewController : UIViewController <UITextViewDelegate>

    // public properties
    @property (weak, nonatomic) NSString *prefilledText;

@end
