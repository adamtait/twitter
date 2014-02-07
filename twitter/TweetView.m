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
#import "SVProgressHUD.h"

@interface TweetView ()

    // gesture recognizers
    - (void)replyImageWasTouched:(UITapGestureRecognizer *)recognizer;
    - (void)retweetImageWasTouched:(UITapGestureRecognizer *)recognizer;
    - (void)favoriteImageWasTouched:(UITapGestureRecognizer *)recognizer;

    // constraints
    - (void)initConstraintsToRetweetHeader;

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


#pragma mark - public instance methods


#pragma mark - Initialization and Setup methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [TweetView setupTweetContentWithView:self];
    }
    return self;
}

+ (void)setupTweetContentWithView:(TweetView *)view
{
    view.hasBeenFavorited = NO;
    view.hasBeenRetweeted = NO;
    
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    // remove all subviews from the UITableViewCell contentView
    [[view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // add TweetTextView and order it at the back
    view.content = [[TweetTextView alloc] init];
    [view addSubview:[view.content getTextView]];
    
    // add retweet header
    view.retweetHeaderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"retweet.png"]];
    view.retweetHeaderLabel = [TweetView setupLabelWithFont:[UIFont systemFontOfSize:12.0] textColor:[Color fontGray]];
    [view addSubview:view.retweetHeaderLabel];
    [view initConstraintsToRetweetHeader];
    
    // add profileImage & username & userhandle to contentView
    view.profileImageView = [TweetView setupImageView];
    view.usernameLabel = [TweetView setupLabelWithFont:[UIFont boldSystemFontOfSize:14.0] textColor:[Color fontBlack]];
    view.userhandleLabel = [TweetView setupLabelWithFont:[UIFont systemFontOfSize:12.0] textColor:[Color fontGray]];
    view.dateLabel = [TweetView setupLabelWithFont:[UIFont systemFontOfSize:12.0] textColor:[Color fontGray]];
    [view addSubview:view.profileImageView];
    [view addSubview:view.usernameLabel];
    [view addSubview:view.userhandleLabel];
    [view addSubview:view.dateLabel];
    
    // add tweet action UIImageViews
    view.replyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reply.png"]];
    [view.replyImageView setUserInteractionEnabled:YES];
    view.retweetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"retweet.png"]];
    [view.retweetImageView setUserInteractionEnabled:YES];
    view.favoriteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorite.png"]];
    [view.favoriteImageView setUserInteractionEnabled:YES];
    [view addSubview:view.replyImageView];
    [view addSubview:view.retweetImageView];
    [view addSubview:view.favoriteImageView];
    
    // add gesture recognizers for the tweet action images/buttons
    [view.replyImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(replyImageWasTouched:)]];
    [view.retweetImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(retweetImageWasTouched:)]];
    [view.favoriteImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(favoriteImageWasTouched:)]];
}


#pragma mark - update content & contraints on subviews

- (void)updateContentWithTweet:(Tweet *)tweet
{
    _tweet = tweet;
    
    // update subviews with tweet information
    [TweetView loadImageFromUrl:tweet.profileImageURL imageView:_profileImageView];
    _usernameLabel.text = tweet.username;
    [_usernameLabel sizeToFit];
    _userhandleLabel.text = tweet.userhandle;
    _dateLabel.text = tweet.createdAt;
    [self setFavorited:tweet.favorited];
    [self setRetweeted:tweet.retweetedByMe];
    
    if (tweet.retweeted)
    {
        _retweetHeaderLabel.text = tweet.retweeterUserhandle;
        [_retweetHeaderLabel sizeToFit];
        _retweetHeaderLabelHeightConstraint.constant = _retweetHeaderLabel.frame.size.height;
        [self addSubview:_retweetHeaderImageView];
    }
    else
    {
        _retweetHeaderLabelHeightConstraint.constant = 0;
        [_retweetHeaderImageView removeFromSuperview];
    }
    
    // update TextView content
    [_content updateContentWithString:tweet.text];
    [self bringSubviewToFront:[_content getTextView]];
}


#pragma setup UIKit objects


+ (UILabel *)setupLabelWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.numberOfLines = 1;
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
                                                              [SVProgressHUD showErrorWithStatus:@"network error"];
                                                          }];
    [operation start];
}


#pragma mark - View state methods

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

- (void)setRetweeted:(BOOL)retweeted
{
    _hasBeenRetweeted = retweeted;
    UIImage *image;
    if (_hasBeenRetweeted) {
        image = [UIImage imageNamed:@"retweet_on.png"];
    } else {
        image = [UIImage imageNamed:@"retweet.png"];
    }
    [_retweetImageView setImage:image];
}

# pragma gesture recognizers


- (void)replyImageWasTouched:(UITapGestureRecognizer *)recognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"replyToTweet" object:_tweet];
}

- (void)retweetImageWasTouched:(UITapGestureRecognizer *)recognizer
{
    if (!self.hasBeenRetweeted) {
        [_tweet createRetweet];
    } else {
        [_tweet deleteRetweet];
    }
    [self setRetweeted:!self.hasBeenRetweeted];
}

- (void)favoriteImageWasTouched:(UITapGestureRecognizer *)recognizer
{
    [self setFavorited:!self.hasBeenFavorited];
    [_tweet toggleFavorite];
}


#pragma mark - contraints

- (void)initConstraintsToRetweetHeader
{
    _retweetHeaderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _retweetHeaderLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_retweetHeaderLabel
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1
                                                                             constant:0];
    [_retweetHeaderLabel addConstraint:_retweetHeaderLabelHeightConstraint];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|-7-[_retweetHeaderLabel]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(_retweetHeaderLabel)]];
}

@end
