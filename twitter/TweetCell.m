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
#import "TweetView.h"

@interface TweetCell ()

    // private properties
    @property (nonatomic, strong) TweetView *view;
    @property (nonatomic, strong) Tweet *tweet;

    // private methods <UIResponder>
    - (void)tweetActions:(UITapGestureRecognizer *)recognizer;

@end


@implementation TweetCell


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
        
        _view = [[TweetView alloc] initWithFrame:self.contentView.frame];
        [self.contentView addSubview:_view];
        
        // add gesture recognizers
//        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tweetActions:)]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (void)updateContentWithTweet:(Tweet *)tweet
{
    _tweet = tweet;
    [_view updateContentWithTweet:tweet];
}



#pragma UIResponder methods

- (void)tweetActions:(UITapGestureRecognizer *)recognizer
{
    int yPositionOfContent;
    if (_tweet.retweeted) {
        yPositionOfContent = [TweetView defaultContentFrameWithRetweetHeader].origin.y;
    } else {
        yPositionOfContent = [TweetView defaultContentFrame].origin.y;
    }
    int height = yPositionOfContent + [_view.content getLayoutHeightForWidth:275.0] + 25;
    CGPoint p = [recognizer locationInView:self];
    
    CGRect replyAction = CGRectMake(40, (height-5-16), 16, 16);
    CGRect retweetAction = CGRectMake((40+16+25), (height-5-16), 16, 16);
    CGRect favoriteAction = CGRectMake((40+16+25+16+25), (height-5-16), 16, 16);
    
    if (CGRectContainsPoint(replyAction, p))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"replyToTweet" object:_tweet];
    }
    else if (CGRectContainsPoint(retweetAction, p))
    {
        if (!_view.hasBeenRetweeted) {
            [_view setRetweeted];
            [self.tweet createRetweet];
        }
    }
    else if (CGRectContainsPoint(favoriteAction, p))
    {
        [_view setFavorited:!_view.hasBeenFavorited];
        [self.tweet toggleFavorite];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tweetWasSelected" object:self.tweet];
    }
}


@end
