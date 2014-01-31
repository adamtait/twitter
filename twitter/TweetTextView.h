//
//  CellTextView.h
//  Todo
//
//  Created by Adam Tait on 1/26/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetTextView : NSObject

    // public static methods
    + (UIFont *)defaultFont;
    + (NSLineBreakMode)defaultLineBreakMode;

    // public initializers
    - (id)initWithFrame:(CGRect)frame;

    // accessors
    - (UITextView *)getTextView;
    - (void)updateContentWithString:(NSString *)content;

@end
