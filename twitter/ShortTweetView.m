//
//  ShortTweetView.m
//  twitter
//
//  Created by Adam Tait on 2/6/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import "ShortTweetView.h"

@implementation ShortTweetView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addConstraintsToHeaderLine];
        [self addConstraintsToTweetTextView];
        [self addConstraintsToFooterLine];
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
    
    // add vertical constraints to profileImage View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:super.retweetHeaderLabel attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual toItem:profileImageView
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:-7]];
    
    // add vertical constraints to username, userhandle & date labels
    [self addConstraint:[NSLayoutConstraint constraintWithItem:super.retweetHeaderLabel attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual toItem:usernameLabel
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:-5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:super.retweetHeaderLabel attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual toItem:userhandleLabel
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:-7]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:super.retweetHeaderLabel attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual toItem:dateLabel
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:-7]];
    
    // add constraints for shrinking of the userhandleLabel (lower priority)
    NSLayoutConstraint *userhandleLabelWidthConstraint = [NSLayoutConstraint constraintWithItem:userhandleLabel
                                                                                      attribute:NSLayoutAttributeWidth
                                                                                      relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                         toItem:nil
                                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                                     multiplier:1
                                                                                       constant:20];
    userhandleLabelWidthConstraint.priority = UILayoutPriorityDefaultLow;
    [self addConstraint:userhandleLabelWidthConstraint];
    
    // add constraints separating all labels & images
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-7-[profileImageView]-7-[usernameLabel]-5-[userhandleLabel]-(>=5)-[dateLabel]-5-|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(profileImageView, usernameLabel, userhandleLabel, dateLabel)]];
}


- (void)addConstraintsToTweetTextView
{
    UITextView *tweetTextView = [super.content getTextView];
    UILabel *usernameLabel = super.userhandleLabel;
    
    tweetTextView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-40-[tweetTextView]-5-|"
                          options:NSLayoutFormatDirectionLeftToRight
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(tweetTextView)]];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[usernameLabel]-5-[tweetTextView]"
                          options:NSLayoutFormatDirectionLeftToRight
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(usernameLabel, tweetTextView)]];
    
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
    UITextView *tweetTextView = [super.content getTextView];
    
    UIImageView *replyImageView = super.replyImageView;
    UIImageView *retweetImageView = super.retweetImageView;
    UIImageView *favoriteImageView = super.favoriteImageView;
    
    replyImageView.translatesAutoresizingMaskIntoConstraints = NO;
    retweetImageView.translatesAutoresizingMaskIntoConstraints = NO;
    favoriteImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // add vertical constraints to replyImageView
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[tweetTextView]-[replyImageView]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(tweetTextView, replyImageView)]];
    // add vertical constraints to retweetImageView
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[tweetTextView]-[retweetImageView]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(tweetTextView, retweetImageView)]];
    // add vertical constraints to favoriteImageView
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[tweetTextView]-[favoriteImageView]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(tweetTextView, favoriteImageView)]];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-40-[replyImageView]-25-[retweetImageView]-25-[favoriteImageView]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(replyImageView, retweetImageView, favoriteImageView)]];
    
}


- (CGFloat)getLayoutHeight
{
    CGFloat textViewHeight = 10 + [super.content getLayoutHeightForWidth:275.0];
    CGFloat headerLineHeight = 5 + 20;
    CGFloat footerLineHeight = super.replyImageView.frame.size.height;
    CGFloat retweetHeaderLineBuffer = 30;
    return textViewHeight + headerLineHeight + footerLineHeight + retweetHeaderLineBuffer;
}


@end
