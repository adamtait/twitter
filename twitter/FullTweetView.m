//
//  FullTweetView.m
//  twitter
//
//  Created by Adam Tait on 2/6/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import "FullTweetView.h"
#import <QuartzCore/QuartzCore.h>
#import "AFImageRequestOperation.h"
#import "TweetView.h"
#import "Color.h"
#import "SVProgressHUD.h"



@interface FullTweetView ()

// private instance methods
- (CGFloat)getLayoutHeight;

// handling constraints
@property (nonatomic, strong) NSLayoutConstraint *retweetHeaderLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *tweetTextViewHeightConstraint;
- (void)initConstraintsToRetweetHeader;
- (void)addConstraintsToHeaderLine;
- (void)addConstraintsToTweetTextView;
- (void)addConstraintsToRetweetHeaderLine;

@end


@implementation FullTweetView

#pragma public instance methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addConstraintsToHeaderLine];
        [self addConstraintsToTweetTextView];
        [self addConstraintsToFooterLine];
        [super.content getTextView].font = [TweetTextView largerFont];
    }
    return self;
}

- (void)updateContentWithTweet:(Tweet *)tweet
{
    [super updateContentWithTweet:tweet];
    
    if (tweet.retweeted)
    {
        [self addConstraintsToRetweetHeaderLine];
    }
    // update height constraint on the TweetTextView
    super.tweetTextViewHeightConstraint.constant = [super.content getLayoutHeightForWidth:275.0];
    
    // update height on the view frame
    CGRect frame = self.frame;
    frame.size.height = [self getLayoutHeight];
    self.frame = frame;
}


#pragma adding & handling constraints

- (void)initConstraintsToRetweetHeader
{
    super.retweetHeaderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    super.retweetHeaderLabelHeightConstraint = [NSLayoutConstraint
                                                constraintWithItem:super.retweetHeaderLabel attribute:NSLayoutAttributeHeight
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                multiplier:1 constant:0];
    [super.retweetHeaderLabel addConstraint:super.retweetHeaderLabelHeightConstraint];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                         toItem:super.retweetHeaderLabel attribute:NSLayoutAttributeTop
                         multiplier:1 constant:-7]];
}

- (void)addConstraintsToRetweetHeaderLine
{
    UIImageView *retweetHeaderImageView = super.retweetHeaderImageView;
    UILabel *retweetHeaderLabel = super.retweetHeaderLabel;
    
    retweetHeaderImageView.translatesAutoresizingMaskIntoConstraints = NO;
    retweetHeaderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // add vertical constraints to retweetHeaderImageView
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|-5-[retweetHeaderImageView]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(retweetHeaderImageView)]];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-30-[retweetHeaderImageView]-4-[retweetHeaderLabel]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(retweetHeaderImageView, retweetHeaderLabel)]];
}

- (void)addConstraintsToHeaderLine
{
    UIImageView *profileImageView = super.profileImageView;
    UILabel *usernameLabel = super.usernameLabel;
    UILabel *userhandleLabel = super.userhandleLabel;
    UILabel *dateLabel = super.dateLabel;
    
    // remove auto layout constraints. they make bad guesses at the needed constraints and take high priority
    profileImageView.translatesAutoresizingMaskIntoConstraints = NO;
    usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    userhandleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // add constraints to profileImage View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:super.retweetHeaderLabel attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual toItem:profileImageView
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:-7]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:profileImageView attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:profileImageView attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50]];
    
    // add vertical constraints to username, userhandle & date labels
    [self addConstraint:[NSLayoutConstraint constraintWithItem:super.retweetHeaderLabel attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual toItem:usernameLabel
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:usernameLabel attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual toItem:userhandleLabel
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:-5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:[super.content getTextView] attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual toItem:dateLabel
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:-5]];
    
    // add constraints separating all labels & images
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-7-[profileImageView]-7-[usernameLabel]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(profileImageView, usernameLabel)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-7-[profileImageView]-7-[userhandleLabel]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(profileImageView, userhandleLabel)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-10-[dateLabel]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(profileImageView, usernameLabel, userhandleLabel, dateLabel)]];
}


- (void)addConstraintsToTweetTextView
{
    UITextView *tweetTextView = [super.content getTextView];
    
    tweetTextView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-10-[tweetTextView]-10-|"
                          options:NSLayoutFormatDirectionLeftToRight
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(tweetTextView)]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:super.profileImageView
                         attribute:NSLayoutAttributeBottom
                         relatedBy:NSLayoutRelationEqual
                         toItem:tweetTextView
                         attribute:NSLayoutAttributeTop
                         multiplier:1
                         constant:-5]];
    
    super.tweetTextViewHeightConstraint = [NSLayoutConstraint constraintWithItem:tweetTextView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:0];
    [self addConstraint:super.tweetTextViewHeightConstraint];
}

- (void)addConstraintsToFooterLine
{
    UIImageView *replyImageView = super.replyImageView;
    UIImageView *retweetImageView = super.retweetImageView;
    UIImageView *favoriteImageView = super.favoriteImageView;
    UILabel *dateLabel = super.dateLabel;
    
    replyImageView.translatesAutoresizingMaskIntoConstraints = NO;
    retweetImageView.translatesAutoresizingMaskIntoConstraints = NO;
    favoriteImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // add vertical constraints to replyImageView
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[dateLabel]-[replyImageView]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(dateLabel, replyImageView)]];
    // add vertical constraints to retweetImageView
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[dateLabel]-[retweetImageView]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(dateLabel, retweetImageView)]];
    // add vertical constraints to favoriteImageView
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[dateLabel]-[favoriteImageView]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(dateLabel, favoriteImageView)]];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-40-[replyImageView]-40-[retweetImageView]-40-[favoriteImageView]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(replyImageView, retweetImageView, favoriteImageView)]];
    
    // add width & height constraints
    for (UIImageView *tweetActionImageView in [NSArray arrayWithObjects:replyImageView, retweetImageView, favoriteImageView, nil]) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:tweetActionImageView attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:tweetActionImageView attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
    }
    
}


- (CGFloat)getLayoutHeight
{
    CGFloat textViewHeight = 10 + [super.content getLayoutHeightForWidth:275.0];
    CGFloat headerLineHeight = 5 + 20;
    CGFloat footerLineHeight = super.replyImageView.frame.size.height;
    CGFloat retweetHeaderLineBuffer = 30;
    return textViewHeight + headerLineHeight + footerLineHeight + retweetHeaderLineBuffer + 100;
}

@end
