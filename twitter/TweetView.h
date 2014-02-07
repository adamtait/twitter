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
    + (void)setupTweetContentWithView:(TweetView *)view;
    + (CGRect)defaultContentFrame;
    + (CGRect)defaultContentFrameWithRetweetHeader;
    + (UILabel *)setupLabelWithFont:(UIFont *)font textColor:(UIColor *)textColor;
    + (UIImageView *)setupImageView;
    + (void)loadImageFromUrl:(NSString *)url imageView:(UIImageView *)imageView;

    // public properties
    @property (nonatomic, strong) Tweet *tweet;
    @property (nonatomic, strong) TweetTextView *content;
    @property (nonatomic, strong) UIImageView *profileImageView;
    @property (nonatomic, strong) UILabel *usernameLabel;
    @property (nonatomic, strong) UILabel *userhandleLabel;
    @property (nonatomic, strong) UILabel *dateLabel;
    @property (nonatomic, strong) UIImageView *replyImageView;
    @property (nonatomic, strong) UIImageView *retweetImageView;
    @property (nonatomic, strong) UIImageView *favoriteImageView;
    @property (nonatomic, strong) UIImageView *retweetHeaderImageView;
    @property (nonatomic, strong) UILabel *retweetHeaderLabel;
    @property BOOL hasBeenFavorited;
    @property BOOL hasBeenRetweeted;

    // public constraints
    @property (nonatomic, strong) NSLayoutConstraint *retweetHeaderLabelHeightConstraint;
    @property (nonatomic, strong) NSLayoutConstraint *tweetTextViewHeightConstraint;

    // public methods
    - (void)updateContentWithTweet:(Tweet *)tweet;
    - (void)setFavorited:(BOOL)favorited;
    - (void)setRetweeted:(BOOL)retweeted;

@end
