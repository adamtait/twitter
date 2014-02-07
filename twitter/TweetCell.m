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
#import "ShortTweetView.h"

@interface TweetCell ()

    // private properties
    @property (nonatomic, strong) ShortTweetView *view;

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
        
        _view = [[ShortTweetView alloc] initWithFrame:self.contentView.frame];
        [self.contentView addSubview:_view];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)updateContentWithTweet:(Tweet *)tweet
{
    [_view updateContentWithTweet:tweet];
}

@end
