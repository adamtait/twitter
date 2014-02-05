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

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) NSTextContainer *container;
@property (nonatomic, strong) NSTextStorage *storage;
@property (nonatomic, strong) NSLayoutManager *layout;

@end

@implementation TweetTextView

#pragma public static methods

+ (UIFont *)defaultFont
{
    return [UIFont systemFontOfSize:14.0];
}

+ (NSLineBreakMode)defaultLineBreakMode
{
    return NSLineBreakByWordWrapping;
}

#pragma public instance methods

- (id)init
{
    self = [super init];
    if (self) {
        _textView = [[UITextView alloc] init];
        
        _textView.font = [TweetTextView defaultFont];
        _textView.textContainerInset = UIEdgeInsetsZero;
        _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _textView.editable = NO;
    }
    return self;
}

- (UITextView *)getTextView
{
    return _textView;
}

- (void)updateContentWithString:(NSString *)content
{
    _textView.attributedText = [[NSAttributedString alloc] initWithString:content];
}

- (int)getLayoutHeightForWidth:(CGFloat)width
{
    
    CGSize size = [_textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}

@end
