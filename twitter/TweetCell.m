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

    // private UIKit objects
    @property (nonatomic, strong) UIImageView *profileImageView;
    @property (nonatomic, strong) UILabel *usernameLabel;
    @property (nonatomic, strong) UILabel *userhandleLabel;
    @property (nonatomic, strong) TweetTextView *content;

    // private methods
    - (TweetTextView *)setupTweetTextView;
    - (UILabel *)setupLabelWithFont:(UIFont *)font textColor:(UIColor *)textColor;
    - (UIImageView *)setupImageViewWithFrame:(CGRect)frame;
    - (void)loadImageFromUrl:(NSString *)url imageView:(UIImageView *)imageView;
    - (void)addConstraintsToSubviews;

@end




@implementation TweetCell

#pragma public static methods

+ (CGRect)defaultContentFrame
{
    return CGRectMake(40, 30, 270, 80);
}


#pragma private static methods

+ (CGRect)defaultProfileImageFrame
{
    return CGRectMake(5, 10, 30, 35);
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
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // remove all subviews from the UITableViewCell contentView
        [[self.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        // add profileImage & username & userhandle to contentView
        _profileImageView = [self setupImageViewWithFrame:[TweetCell defaultProfileImageFrame]];
        _usernameLabel = [self setupLabelWithFont:[UIFont boldSystemFontOfSize:14.0] textColor:[Color fontBlack]];
        _userhandleLabel = [self setupLabelWithFont:[UIFont systemFontOfSize:12.0] textColor:[Color fontBlack]];
        [self.contentView addSubview:_profileImageView];
        [self.contentView addSubview:_usernameLabel];
        [self.contentView addSubview:_userhandleLabel];
        [self addConstraintsToSubviews];
        
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
    [self loadImageFromUrl:_tweet.profileImageURL imageView:_profileImageView];
    _usernameLabel.text = _tweet.username;
    [_usernameLabel sizeToFit];
    
    _userhandleLabel.text = _tweet.userhandle;
    [_content updateContentWithString:tweet.text];
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


- (void)addConstraintsToSubviews
{
    UILabel *usernameLabel = _usernameLabel;
    UILabel *userhandleLabel = _userhandleLabel;
    
    // remove auto layout constraints. they make bad guesses at the needed constraints and take high priority
    usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    userhandleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // add horizontal & vertical constraints to usernameLabel
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|-5-[usernameLabel]"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(usernameLabel)]];
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|-40-[usernameLabel]"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(usernameLabel)]];
    
    // add constraint separating usernameLabel & userhandleLabel
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:usernameLabel attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual toItem:userhandleLabel
                                                                 attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-10.0]];
    
    // add horizontal & vertical constraints to userhandleLabel
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|-5-[userhandleLabel]"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(userhandleLabel)]];
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:[userhandleLabel]-(>=20)-|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(userhandleLabel)]];
}


@end
