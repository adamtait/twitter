//
//  TweetCell.m
//  twitter
//
//  Created by Adam Tait on 1/30/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//


#import "TweetCell.h"
#import "TweetTextView.h"
#import "Color.h"

@interface TweetCell ()

    // private static methods
    + (CGRect)defaultUsernameFrame;
    + (CGRect)defaultUserhandleFrame;

    // private properties
    @property (nonatomic, strong) Tweet *tweet;

    // private UIKit objects
    @property (nonatomic, strong) UILabel *username;
    @property (nonatomic, strong) UILabel *userhandle;
    @property (nonatomic, strong) TweetTextView *content;

    // private methods
    - (TweetTextView *)setupTweetTextView;
    - (UILabel *)setupLabelWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)textColor;

@end

@implementation TweetCell



#pragma public static methods

+ (CGRect)defaultContentFrame
{
    return CGRectMake(10, 40, 300, 60);
}


#pragma private static methods

+ (CGRect)defaultUsernameFrame
{
    return CGRectMake(10, 5, 140, 20);
}

+ (CGRect)defaultUserhandleFrame
{
    return CGRectMake(155, 5, 100, 20);
}






#pragma public instance methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.indentationLevel = 0;
        self.indentationWidth = 0.0;
        self.shouldIndentWhileEditing = NO;
        self.separatorInset = UIEdgeInsetsZero;
        
        // remove all subviews from the UITableViewCell contentView
        [[self.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        // add username & userhandle to contentView
        _username = [self setupLabelWithFrame:[TweetCell defaultUsernameFrame] font:[UIFont boldSystemFontOfSize:14.0] textColor:[Color fontBlack]];
        _userhandle = [self setupLabelWithFrame:[TweetCell defaultUserhandleFrame] font:[UIFont systemFontOfSize:12.0] textColor:[Color fontBlack]];
        [self.contentView addSubview:_username];
        [self.contentView addSubview:_userhandle];
        
        // add tweetTextView to contentView
        [self.contentView addSubview:[[self setupTweetTextView] getTextView]];
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
    _username.text = _tweet.username;
    _userhandle.text = _tweet.userhandle;
    [_content updateContentWithString:tweet.text];
}


#pragma setup UIKit objects

- (TweetTextView *)setupTweetTextView
{
    _content = [[TweetTextView alloc] initWithFrame:[TweetCell defaultContentFrame]];
    return _content;
}

- (UILabel *)setupLabelWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
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


@end
