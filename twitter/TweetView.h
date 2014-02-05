//
//  TweetView.h
//  twitter
//
//  Created by Adam Tait on 2/2/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "TweetTextView.h"

@interface TweetView : UIView

    // public static methods
    + (CGRect)defaultContentFrame;
    + (CGRect)defaultContentFrameWithRetweetHeader;
    + (UILabel *)setupLabelWithFont:(UIFont *)font textColor:(UIColor *)textColor;
    + (UIImageView *)setupImageView;
    + (void)loadImageFromUrl:(NSString *)url imageView:(UIImageView *)imageView;

    // public properties
    @property (nonatomic, strong) TweetTextView *content;
    @property BOOL hasBeenFavorited;
    @property BOOL hasBeenRetweeted;

    // public methods
    - (void)updateContentWithTweet:(Tweet *)tweet;
    - (void)setFavorited:(BOOL)favorited;
    - (void)setRetweeted;

@end
