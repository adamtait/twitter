//
//  TweetCell.m
//  twitter
//
//  Created by Adam Tait on 1/30/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AFImageRequestOperation.h"
#import "TweetCell.h"
#import "TweetTextView.h"
#import "Color.h"

@interface TweetCell ()

    // private properties
    @property (nonatomic, strong) Tweet *tweet;
    @property BOOL hasBeenfavorited;

    // private UIKit objects
    @property (nonatomic, strong) UIImageView *profileImageView;
    @property (nonatomic, strong) UILabel *usernameLabel;
    @property (nonatomic, strong) UILabel *userhandleLabel;
    @property (nonatomic, strong) UILabel *dateLabel;
    @property (nonatomic, strong) TweetTextView *content;
    @property (nonatomic, strong) UIImageView *replyImageView;
    @property (nonatomic, strong) UIImageView *retweetImageView;
    @property (nonatomic, strong) UIImageView *favoriteImageView;

    // private methods
    - (TweetTextView *)setupTweetTextView;
    - (UILabel *)setupLabelWithFont:(UIFont *)font textColor:(UIColor *)textColor;
    - (UIImageView *)setupImageViewWithFrame:(CGRect)frame;
    - (void)loadImageFromUrl:(NSString *)url imageView:(UIImageView *)imageView;
    - (void)setFavorited:(BOOL)favorited;

    - (void)addConstraintsToHeaderLine;
    - (void)addConstraintsToFooterLine;

    // UIResponder
    - (void)toggleFavorite:(UITapGestureRecognizer *)recognizer;

@end




@implementation TweetCell

#pragma public static methods

+ (CGRect)defaultContentFrame
{
    return CGRectMake((7 + 25 + 5), 25, 274, 120);
}


#pragma private static methods

+ (CGRect)defaultProfileImageFrame
{
    return CGRectMake(7, 7, 25, 25);
}




#pragma public instance methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _hasBeenfavorited = NO;
        
        self.indentationLevel = 0;
        self.indentationWidth = 0.0;
        self.shouldIndentWhileEditing = NO;
        self.separatorInset = UIEdgeInsetsZero;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // remove all subviews from the UITableViewCell contentView
        [[self.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        // add tweetTextView to contentView
        [self.contentView addSubview:[[self setupTweetTextView] getTextView]];
        
        // add profileImage & username & userhandle to contentView
        _profileImageView = [self setupImageViewWithFrame:[TweetCell defaultProfileImageFrame]];
        _usernameLabel = [self setupLabelWithFont:[UIFont boldSystemFontOfSize:14.0] textColor:[Color fontBlack]];
        _userhandleLabel = [self setupLabelWithFont:[UIFont systemFontOfSize:12.0] textColor:[Color fontGray]];
        _dateLabel = [self setupLabelWithFont:[UIFont systemFontOfSize:12.0] textColor:[Color fontGray]];
        [self.contentView addSubview:_profileImageView];
        [self.contentView addSubview:_usernameLabel];
        [self.contentView addSubview:_userhandleLabel];
        [self.contentView addSubview:_dateLabel];
        [self addConstraintsToHeaderLine];
        
        // add the twitter action images to contentView
        _replyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reply.png"]];
        _retweetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"retweet.png"]];
        _favoriteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorite.png"]];
        [self.contentView addSubview:_replyImageView];
        [self.contentView addSubview:_retweetImageView];
        [self.contentView addSubview:_favoriteImageView];
        [self addConstraintsToFooterLine];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)updateContentWithTweet:(Tweet *)tweet
{
    _tweet = tweet;
    [self loadImageFromUrl:_tweet.profileImageURL imageView:_profileImageView];
    _usernameLabel.text = _tweet.username;
    [_usernameLabel sizeToFit];
    
    _userhandleLabel.text = _tweet.userhandle;
    _dateLabel.text = _tweet.createdAt;
    
    [_content updateContentWithString:tweet.text];
    
    [self setFavorited:tweet.favorited];

    // add gesture recognizers
    UITapGestureRecognizer *favoriteGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFavorite:)];
    [self.contentView addGestureRecognizer:favoriteGestureRecognizer];
}


#pragma setup UIKit objects

- (TweetTextView *)setupTweetTextView
{
    _content = [[TweetTextView alloc] initWithFrame:[TweetCell defaultContentFrame]];
    return _content;
}

- (UILabel *)setupLabelWithFont:(UIFont *)font textColor:(UIColor *)textColor
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


- (UIImageView *)setupImageViewWithFrame:(CGRect)frame
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.layer.cornerRadius = 4.0;
    imageView.clipsToBounds = YES;
    return imageView;
}

- (void)loadImageFromUrl:(NSString *)url imageView:(UIImageView *)imageView
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
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
    _hasBeenfavorited = favorited;
    UIImage *image;
    if (_hasBeenfavorited) {
         image = [UIImage imageNamed:@"favorite_on.png"];
    } else {
        image = [UIImage imageNamed:@"favorite.png"];
    }
    [_favoriteImageView setImage:image];
}



#pragma adding & handling constraints


- (void)addConstraintsToHeaderLine
{
    UILabel *usernameLabel = _usernameLabel;
    UILabel *userhandleLabel = _userhandleLabel;
    UILabel *dateLabel = _dateLabel;
    
    // remove auto layout constraints. they make bad guesses at the needed constraints and take high priority
    usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    userhandleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // add vertical constraints to usernameLabel
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|-5-[usernameLabel]"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(usernameLabel)]];
    
    // add vertical constraints to userhandleLabel
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|-7-[userhandleLabel]"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(userhandleLabel)]];
    
    // add vertical constraints to dateLabel
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|-7-[dateLabel]"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(dateLabel)]];
    
    // add constraints separating usernameLabel & userhandleLabel & dateLabel
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|-40-[usernameLabel]-5-[userhandleLabel]-(>=5)-[dateLabel]-5-|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(usernameLabel, userhandleLabel, dateLabel)]];
    
}


- (void)addConstraintsToFooterLine
{
    UIImageView *replyImageView = _replyImageView;
    UIImageView *retweetImageView = _retweetImageView;
    UIImageView *favoriteImageView = _favoriteImageView;
    
    replyImageView.translatesAutoresizingMaskIntoConstraints = NO;
    retweetImageView.translatesAutoresizingMaskIntoConstraints = NO;
    favoriteImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // add vertical constraints to replyImageView
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:[replyImageView]-5-|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(replyImageView)]];
    // add vertical constraints to retweetImageView
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:[retweetImageView]-5-|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(retweetImageView)]];
    // add vertical constraints tp favoriteImageView
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:[favoriteImageView]-5-|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(favoriteImageView)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|-40-[replyImageView]-25-[retweetImageView]-25-[favoriteImageView]"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(replyImageView, retweetImageView, favoriteImageView)]];
    
}



#pragma UIResponder methods

- (void)toggleFavorite:(UITapGestureRecognizer *)recognizer
{
    int height = [TweetCell defaultContentFrame].origin.y + [_content getLayoutHeight] + 25;
    CGPoint p = [recognizer locationInView:self.contentView];
    if (CGRectContainsPoint(CGRectMake((40+16+25+16+25), (height-5-16), 16, 16), p)) {
        [self setFavorited:!_hasBeenfavorited];
        [self.tweet toggleFavorite];
    }
}







@end
