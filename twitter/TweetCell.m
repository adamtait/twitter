//
//  TweetCell.m
//  twitter
//
//  Created by Adam Tait on 1/30/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//


#import "TweetCell.h"
#import "TweetTextView.h"

@interface TweetCell ()

    // private properties
    @property (nonatomic, strong) Tweet *tweet;

    // private UIKit objects
    @property (nonatomic, strong) TweetTextView *content;

    // private methods
    - (TweetTextView *)setupTweetTextView;

@end

@implementation TweetCell



#pragma public static methods

+ (CGRect)defaultContentFrame
{
    return CGRectMake(10, 40, 300, 60);
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
    [_content updateContentWithString:tweet.text];
//    [self setNeedsDisplay];
}


#pragma setup UIKit objects

- (TweetTextView *)setupTweetTextView
{
    _content = [[TweetTextView alloc] initWithFrame:[TweetCell defaultContentFrame]];
    return _content;
}


@end
