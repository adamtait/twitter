//
//  CellTextView.m
//  Todo
//
//  Created by Adam Tait on 1/26/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import "TweetTextView.h"
#import "TweetView.h"

@interface TweetTextView  ()

    // private properties
    @property (nonatomic, strong) UITextView *textView;

@end

@implementation TweetTextView

#pragma public static methods

+ (UIFont *)defaultFont
{
    return [UIFont systemFontOfSize:14.0];
}


#pragma public instance methods

- (id)init
{
    self = [super init];
    if (self) {
        _textView = [[UITextView alloc] init];
        
        _textView.font = [TweetTextView defaultFont];
        _textView.textContainerInset = UIEdgeInsetsZero;
        _textView.editable = NO;
        [_textView setUserInteractionEnabled:NO];
    }
    return self;
}

- (UITextView *)getTextView
{
    return _textView;
}

- (void)updateContentWithString:(NSString *)content
{
    _textView.text = content;
}

- (int)getLayoutHeightForWidth:(CGFloat)width
{
    
    CGSize size = [_textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}

@end
