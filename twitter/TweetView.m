//
//  TweetView.m
//  twitter
//
//  Created by Adam Tait on 2/2/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import "TweetView.h"
#import <QuartzCore/QuartzCore.h>
#import "AFImageRequestOperation.h"
#import "TweetView.h"
#import "Color.h"

@interface TweetView ()

    // private UIKit objects
    @property (nonatomic, strong) UIImageView *profileImageView;
    @property (nonatomic, strong) UILabel *usernameLabel;
    @property (nonatomic, strong) UILabel *userhandleLabel;
    @property (nonatomic, strong) UILabel *dateLabel;
    @property (nonatomic, strong) UIImageView *replyImageView;
    @property (nonatomic, strong) UIImageView *retweetImageView;
    @property (nonatomic, strong) UIImageView *favoriteImageView;
    @property (nonatomic, strong) UIImageView *retweetHeaderImageView;
    @property (nonatomic, strong) UILabel *retweetHeaderLabel;

    // handling constraints
    - (void)addConstraintsToHeaderLineWithHeightOffset:(int)heightOffset;
    - (int)addConstraintsToRetweetHeaderLine;

@end




@implementation TweetView

#pragma public static methods

+ (CGRect)defaultContentFrame
{
    return CGRectMake((7 + 25 + 5), 25, 274, 125);
}

+ (CGRect)defaultContentFrameWithRetweetHeader
{
    return CGRectMake((7 + 25 + 5), 25 + (5 + 16), 274, 120);
}


#pragma public instance methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _hasBeenFavorited = NO;
        _hasBeenRetweeted = NO;
        
        // remove all subviews from the UITableViewCell contentView
        [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        // add profileImage & username & userhandle to contentView
        _profileImageView = [TweetView setupImageView];
        _usernameLabel = [TweetView setupLabelWithFont:[UIFont boldSystemFontOfSize:14.0] textColor:[Color fontBlack]];
        _userhandleLabel = [TweetView setupLabelWithFont:[UIFont systemFontOfSize:12.0] textColor:[Color fontGray]];
        _dateLabel = [TweetView setupLabelWithFont:[UIFont systemFontOfSize:12.0] textColor:[Color fontGray]];
        [self addSubview:_profileImageView];
        [self addSubview:_usernameLabel];
        [self addSubview:_userhandleLabel];
        [self addSubview:_dateLabel];
    }
    return self;
}

- (void)initTwitterActionImageViewsWithSuperView:(UIView *)superview
{
    // add the twitter action images to superview
    _replyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reply.png"]];
    _retweetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"retweet.png"]];
    _favoriteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorite.png"]];
    [superview addSubview:_replyImageView];
    [superview addSubview:_retweetImageView];
    [superview addSubview:_favoriteImageView];
}

- (void)updateContentWithTweet:(Tweet *)tweet
{
    [TweetView loadImageFromUrl:tweet.profileImageURL imageView:_profileImageView];
    _usernameLabel.text = tweet.username;
    [_usernameLabel sizeToFit];
    
    _userhandleLabel.text = tweet.userhandle;
    _dateLabel.text = tweet.createdAt;
    
    [self setFavorited:tweet.favorited];
    
    if (tweet.retweeted)
    {
        _retweetHeaderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"retweet.png"]];
        [self addSubview:_retweetHeaderImageView];
        _retweetHeaderLabel = [TweetView setupLabelWithFont:[UIFont systemFontOfSize:12.0] textColor:[Color fontGray]];
        _retweetHeaderLabel.text = tweet.originatorUserhandle;
        [self addSubview:_retweetHeaderLabel];
        
        int retweetHeaderHeight = [self addConstraintsToRetweetHeaderLine];
        [self addConstraintsToHeaderLineWithHeightOffset:retweetHeaderHeight];
        _content = [[TweetTextView alloc] initWithFrame:[TweetView defaultContentFrameWithRetweetHeader]];
    }
    else
    {
        [self addConstraintsToHeaderLineWithHeightOffset:0];
        _content = [[TweetTextView alloc] initWithFrame:[TweetView defaultContentFrame]];
    }
    [self addSubview:[_content getTextView]];
    [self sendSubviewToBack:[_content getTextView]];
    
    NSLog(@"updating TweetTextView with new content / %@ /", tweet.text);
    
    [_content updateContentWithString:tweet.text];
}


#pragma setup UIKit objects


+ (UILabel *)setupLabelWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.numberOfLines = 1;
    label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    label.adjustsFontSizeToFitWidth = NO;
    //    label.minimumScaleFactor = 10.0f/12.0f;
    label.clipsToBounds = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = textColor;
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}


+ (UIImageView *)setupImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.layer.cornerRadius = 4.0;
    imageView.clipsToBounds = YES;
    return imageView;
}

+ (void)loadImageFromUrl:(NSString *)url imageView:(UIImageView *)imageView
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFImageRequestOperation *operation =
        [AFImageRequestOperation imageRequestOperationWithRequest:request
                                             imageProcessingBlock:nil
                                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                              [imageView setImage:image];
                                                          }
                                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                              NSLog(@"%@", [error localizedDescription]);
                                                          }];
    [operation start];
}

- (void)setFavorited:(BOOL)favorited
{
    _hasBeenFavorited = favorited;
    UIImage *image;
    if (_hasBeenFavorited) {
        image = [UIImage imageNamed:@"favorite_on.png"];
    } else {
        image = [UIImage imageNamed:@"favorite.png"];
    }
    [_favoriteImageView setImage:image];
}

- (void)setRetweeted
{
    _hasBeenRetweeted = YES;
    [_retweetImageView setImage:[UIImage imageNamed:@"retweet_on.png"]];
}


#pragma adding & handling constraints

- (void)addConstraintsToHeaderLineWithHeightOffset:(int)heightOffset
{
    int verticalBuffer = (heightOffset + 5) * -1;
    
    UIImageView *profileImageView = _profileImageView;
    UILabel *usernameLabel = _usernameLabel;
    UILabel *userhandleLabel = _userhandleLabel;
    UILabel *dateLabel = _dateLabel;
    
    // remove auto layout constraints. they make bad guesses at the needed constraints and take high priority
    profileImageView.translatesAutoresizingMaskIntoConstraints = NO;
    usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    userhandleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // add vertical constraints to profileImage View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual toItem:profileImageView
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:(verticalBuffer - 2)]];
    
    
    // add vertical constraints to username, userhandle & date labels
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual toItem:usernameLabel
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:verticalBuffer]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual toItem:userhandleLabel
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:(verticalBuffer - 2)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual toItem:dateLabel
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:(verticalBuffer - 2)]];
    // add constraints separating all labels & images
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-7-[profileImageView]-7-[usernameLabel]-5-[userhandleLabel]-(>=5)-[dateLabel]-5-|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(profileImageView, usernameLabel, userhandleLabel, dateLabel)]];
}


- (void)addConstraintsToFooterLineWithSuperView:(UIView *)superView
{
    UIImageView *replyImageView = _replyImageView;
    UIImageView *retweetImageView = _retweetImageView;
    UIImageView *favoriteImageView = _favoriteImageView;
    
    replyImageView.translatesAutoresizingMaskIntoConstraints = NO;
    retweetImageView.translatesAutoresizingMaskIntoConstraints = NO;
    favoriteImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // add vertical constraints to replyImageView
    [superView addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[replyImageView]-5-|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(replyImageView)]];
    // add vertical constraints to retweetImageView
    [superView addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[retweetImageView]-5-|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(retweetImageView)]];
    // add vertical constraints to favoriteImageView
    [superView addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[favoriteImageView]-5-|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(favoriteImageView)]];
    
    [superView addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-40-[replyImageView]-25-[retweetImageView]-25-[favoriteImageView]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(replyImageView, retweetImageView, favoriteImageView)]];
    
}

- (int)addConstraintsToRetweetHeaderLine
{
    UIImageView *retweetHeaderImageView = _retweetHeaderImageView;
    UILabel *retweetHeaderLabel = _retweetHeaderLabel;
    
    retweetHeaderImageView.translatesAutoresizingMaskIntoConstraints = NO;
    retweetHeaderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // add vertical constraints to retweetHeaderImageView
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|-5-[retweetHeaderImageView]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(retweetHeaderImageView)]];
    // add vertical constraints to favoriteImageView
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|-5-[retweetHeaderLabel]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(retweetHeaderLabel)]];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-30-[retweetHeaderImageView]-4-[retweetHeaderLabel]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(retweetHeaderImageView, retweetHeaderLabel)]];
    
    return 5 + 16;
}

@end
