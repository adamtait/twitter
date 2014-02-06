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

    @property (nonatomic, strong) Tweet *tweet;

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


    // private instance methods
    - (CGFloat)getLayoutHeight;

    // handling constraints
    @property (nonatomic, strong) NSLayoutConstraint *retweetHeaderLabelHeightConstraint;
    @property (nonatomic, strong) NSLayoutConstraint *tweetTextViewHeightConstraint;
    - (void)initConstraintsToRetweetHeader;
    - (void)addConstraintsToHeaderLine;
    - (void)addConstraintsToTweetTextView;
    - (void)addConstraintsToRetweetHeaderLine;

    // gesture recognizers
    - (void)replyImageWasTouched:(UITapGestureRecognizer *)recognizer;
    - (void)retweetImageWasTouched:(UITapGestureRecognizer *)recognizer;
    - (void)favoriteImageWasTouched:(UITapGestureRecognizer *)recognizer;

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
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        // remove all subviews from the UITableViewCell contentView
        [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        // add TweetTextView and order it at the back
        _content = [[TweetTextView alloc] init];
        [self addSubview:[_content getTextView]];
        
        // add retweet header
        _retweetHeaderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"retweet.png"]];
        _retweetHeaderLabel = [TweetView setupLabelWithFont:[UIFont systemFontOfSize:12.0] textColor:[Color fontGray]];
        [self addSubview:_retweetHeaderLabel];
        [self initConstraintsToRetweetHeader];
        
        // add profileImage & username & userhandle to contentView
        _profileImageView = [TweetView setupImageView];
        _usernameLabel = [TweetView setupLabelWithFont:[UIFont boldSystemFontOfSize:14.0] textColor:[Color fontBlack]];
        _userhandleLabel = [TweetView setupLabelWithFont:[UIFont systemFontOfSize:12.0] textColor:[Color fontGray]];
        _dateLabel = [TweetView setupLabelWithFont:[UIFont systemFontOfSize:12.0] textColor:[Color fontGray]];
        [self addSubview:_profileImageView];
        [self addSubview:_usernameLabel];
        [self addSubview:_userhandleLabel];
        [self addSubview:_dateLabel];
        
        // add tweet action UIImageViews
        _replyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reply.png"]];
        [_replyImageView setUserInteractionEnabled:YES];
        _retweetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"retweet.png"]];
        [_retweetImageView setUserInteractionEnabled:YES];
        _favoriteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorite.png"]];
        [_favoriteImageView setUserInteractionEnabled:YES];
        [self addSubview:_replyImageView];
        [self addSubview:_retweetImageView];
        [self addSubview:_favoriteImageView];
        
        // add constraints
        [self addConstraintsToHeaderLine];
        [self addConstraintsToTweetTextView];
        [self addConstraintsToFooterLine];
        
        // add gesture recognizers for the tweet action images/buttons
        [_replyImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replyImageWasTouched:)]];
        [_retweetImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retweetImageWasTouched:)]];
        [_favoriteImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(favoriteImageWasTouched:)]];
    }
    return self;
}

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
    
    if (tweet.retweeted)
    {
        _retweetHeaderLabel.text = tweet.retweeterUserhandle;
        [_retweetHeaderLabel sizeToFit];
        _retweetHeaderLabelHeightConstraint.constant = _retweetHeaderLabel.frame.size.height;
        [self addSubview:_retweetHeaderImageView];
        [self addConstraintsToRetweetHeaderLine];
    }
    else
    {
        _retweetHeaderLabelHeightConstraint.constant = 0;
        [_retweetHeaderImageView removeFromSuperview];
    }
    
    // update TextView content
    [_content updateContentWithString:tweet.text];
    [self bringSubviewToFront:[_content getTextView]];
    
    // update height constraint on the TweetTextView
    _tweetTextViewHeightConstraint.constant = [_content getLayoutHeightForWidth:275.0];
    
    // update height on the view frame
    CGRect frame = self.frame;
    frame.size.height = [self getLayoutHeight];
    self.frame = frame;
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

- (void)addConstraintsToRetweetHeaderLine
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
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|-30-[retweetHeaderImageView]-4-[retweetHeaderLabel]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(retweetHeaderImageView, retweetHeaderLabel)]];
}

- (void)addConstraintsToHeaderLine
{
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
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_retweetHeaderLabel attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual toItem:profileImageView
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:-7]];
    
    // add vertical constraints to username, userhandle & date labels
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_retweetHeaderLabel attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual toItem:usernameLabel
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:-5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_retweetHeaderLabel attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual toItem:userhandleLabel
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:-7]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_retweetHeaderLabel attribute:NSLayoutAttributeBottom
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
    UITextView *tweetTextView = [_content getTextView];
    UILabel *usernameLabel = _userhandleLabel;
    
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
    
    _tweetTextViewHeightConstraint = [NSLayoutConstraint constraintWithItem:tweetTextView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:0];
    [self addConstraint:_tweetTextViewHeightConstraint];
}

- (void)addConstraintsToFooterLine
{
    UITextView *tweetTextView = [_content getTextView];
    
    UIImageView *replyImageView = _replyImageView;
    UIImageView *retweetImageView = _retweetImageView;
    UIImageView *favoriteImageView = _favoriteImageView;
    
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
    CGFloat textViewHeight = 10 + [_content getLayoutHeightForWidth:275.0];
    CGFloat headerLineHeight = 5 + 20;
    CGFloat footerLineHeight = _replyImageView.frame.size.height;
    CGFloat retweetHeaderLineBuffer = 30;
    return textViewHeight + headerLineHeight + footerLineHeight + retweetHeaderLineBuffer;
}


# pragma gesture recognizers


- (void)replyImageWasTouched:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"reply image was touched");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"replyToTweet" object:_tweet];
}

- (void)retweetImageWasTouched:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"retweet image was touched");
    if (!self.hasBeenRetweeted) {
        [self setRetweeted];
        [_tweet createRetweet];
    }
}

- (void)favoriteImageWasTouched:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"favorite image was touched");
    [self setFavorited:!self.hasBeenFavorited];
    [_tweet toggleFavorite];
}

@end
