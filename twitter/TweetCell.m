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
    @property (nonatomic, strong) UIImageView *retweetHeaderImageView;
    @property (nonatomic, strong) UILabel *retweetHeaderLabel;

    // private methods
    - (void)setFavorited:(BOOL)favorited;

    // handling constraints
    - (void)addConstraintsToHeaderLineWithHeightOffset:(int)heightOffet;
    - (void)addConstraintsToFooterLineWithHeightOffset:(int)heightOffet;
    - (int)addConstraintsToRetweetHeaderLine;

    // UIResponder
    - (void)tweetActions:(UITapGestureRecognizer *)recognizer;

@end




@implementation TweetCell

#pragma public static methods

+ (CGRect)defaultContentFrame
{
    return CGRectMake((7 + 25 + 5), 25, 274, 120);
}

+ (CGRect)defaultContentFrameWithRetweetHeader
{
    return CGRectMake((7 + 25 + 5), 25 + (5 + 16), 274, 120);
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
        
        // add profileImage & username & userhandle to contentView
        _profileImageView = [TweetCell setupImageView];
        _usernameLabel = [TweetCell setupLabelWithFont:[UIFont boldSystemFontOfSize:14.0] textColor:[Color fontBlack]];
        _userhandleLabel = [TweetCell setupLabelWithFont:[UIFont systemFontOfSize:12.0] textColor:[Color fontGray]];
        _dateLabel = [TweetCell setupLabelWithFont:[UIFont systemFontOfSize:12.0] textColor:[Color fontGray]];
        [self.contentView addSubview:_profileImageView];
        [self.contentView addSubview:_usernameLabel];
        [self.contentView addSubview:_userhandleLabel];
        [self.contentView addSubview:_dateLabel];
        
        // add the twitter action images to contentView
        _replyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reply.png"]];
        _retweetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"retweet.png"]];
        _favoriteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorite.png"]];
        [self.contentView addSubview:_replyImageView];
        [self.contentView addSubview:_retweetImageView];
        [self.contentView addSubview:_favoriteImageView];
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
    [TweetCell loadImageFromUrl:_tweet.profileImageURL imageView:_profileImageView];
    _usernameLabel.text = _tweet.username;
    [_usernameLabel sizeToFit];
    
    _userhandleLabel.text = _tweet.userhandle;
    _dateLabel.text = _tweet.createdAt;
    
    [self setFavorited:tweet.favorited];
    
    if (tweet.retweeted)
    {
        _retweetHeaderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"retweet.png"]];
        [self.contentView addSubview:_retweetHeaderImageView];
        _retweetHeaderLabel = [TweetCell setupLabelWithFont:[UIFont systemFontOfSize:12.0] textColor:[Color fontGray]];
        _retweetHeaderLabel.text = tweet.originatorUserhandle;
        [self.contentView addSubview:_retweetHeaderLabel];
        
        int retweetHeaderHeight = [self addConstraintsToRetweetHeaderLine];
        [self addConstraintsToHeaderLineWithHeightOffset:retweetHeaderHeight];
        [self addConstraintsToFooterLineWithHeightOffset:retweetHeaderHeight];
        
        _content = [[TweetTextView alloc] initWithFrame:[TweetCell defaultContentFrameWithRetweetHeader]];
    }
    else
    {
        [self addConstraintsToHeaderLineWithHeightOffset:0];
        [self addConstraintsToFooterLineWithHeightOffset:0];
        
        _content = [[TweetTextView alloc] initWithFrame:[TweetCell defaultContentFrame]];
    }
    [self.contentView addSubview:[_content getTextView]];
    [self.contentView sendSubviewToBack:[_content getTextView]];
    [_content updateContentWithString:tweet.text];

    // add gesture recognizers
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tweetActions:)]];
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

- (void)addConstraintsToHeaderLineWithHeightOffset:(int)heightOffet
{
    int verticalBuffer = (heightOffet + 5) * -1;
    
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
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual toItem:profileImageView
                                                                 attribute:NSLayoutAttributeTop multiplier:1.0 constant:(verticalBuffer - 2)]];

    
    // add vertical constraints to username, userhandle & date labels
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual toItem:usernameLabel
                                                                 attribute:NSLayoutAttributeTop multiplier:1.0 constant:verticalBuffer]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual toItem:userhandleLabel
                                                                 attribute:NSLayoutAttributeTop multiplier:1.0 constant:(verticalBuffer - 2)]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual toItem:dateLabel
                                                                 attribute:NSLayoutAttributeTop multiplier:1.0 constant:(verticalBuffer - 2)]];
    // add constraints separating all labels & images
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|-7-[profileImageView]-7-[usernameLabel]-5-[userhandleLabel]-(>=5)-[dateLabel]-5-|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(profileImageView, usernameLabel, userhandleLabel, dateLabel)]];
    
}


- (void)addConstraintsToFooterLineWithHeightOffset:(int)heightOffet
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
    // add vertical constraints to favoriteImageView
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

- (int)addConstraintsToRetweetHeaderLine
{
    UIImageView *retweetHeaderImageView = _retweetHeaderImageView;
    UILabel *retweetHeaderLabel = _retweetHeaderLabel;
    
    retweetHeaderImageView.translatesAutoresizingMaskIntoConstraints = NO;
    retweetHeaderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // add vertical constraints to retweetHeaderImageView
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|-5-[retweetHeaderImageView]"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(retweetHeaderImageView)]];
    // add vertical constraints to favoriteImageView
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|-5-[retweetHeaderLabel]"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(retweetHeaderLabel)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|-30-[retweetHeaderImageView]-4-[retweetHeaderLabel]"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(retweetHeaderImageView, retweetHeaderLabel)]];
    
    return 5 + 16;
}




#pragma UIResponder methods

- (void)tweetActions:(UITapGestureRecognizer *)recognizer
{
    int yPositionOfContent;
    if (_tweet.retweeted) {
        yPositionOfContent = [TweetCell defaultContentFrameWithRetweetHeader].origin.y;
    } else {
        yPositionOfContent = [TweetCell defaultContentFrame].origin.y;
    }
    int height = yPositionOfContent + [_content getLayoutHeight] + 25;
    CGPoint p = [recognizer locationInView:self.contentView];
    
    CGRect replyAction = CGRectMake(40, (height-5-16), 16, 16);
    CGRect retweetAction = CGRectMake((40+16+25), (height-5-16), 16, 16);
    CGRect favoriteAction = CGRectMake((40+16+25+16+25), (height-5-16), 16, 16);
    
    if (CGRectContainsPoint(replyAction, p))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"replyToTweet" object:self.tweet];
    }
    else if (CGRectContainsPoint(retweetAction, p))
    {
        if (_retweetImageView.image != [UIImage imageNamed:@"retweet_on.png"]) {
            [_retweetImageView setImage:[UIImage imageNamed:@"retweet_on.png"]];
            [self.tweet createRetweet];
        }
    }
    else if (CGRectContainsPoint(favoriteAction, p))
    {
        [self setFavorited:!_hasBeenfavorited];
        [self.tweet toggleFavorite];
    }
}







@end
