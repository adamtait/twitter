//
//  CellTextView.m
//  Todo
//
//  Created by Adam Tait on 1/26/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import "TweetTextView.h"

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

- (id)initWithFrame:(CGRect)frame
{
    _container = [[NSTextContainer alloc] initWithSize:CGSizeMake(frame.size.width, frame.size.height)];
    _container.lineBreakMode = [TweetTextView defaultLineBreakMode];
    self = [super init];
    
    if (self) {
        _layout = [[NSLayoutManager alloc] init];
        [_layout addTextContainer:_container];
        _storage = [[NSTextStorage alloc] init];
        [_storage addLayoutManager:_layout];
        
        _textView = [[UITextView alloc] initWithFrame:frame textContainer:_container];
        
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
    _textView.attributedText = [[NSAttributedString alloc] initWithString:content ];
    
    NSRange range = NSMakeRange(0, [content length]);
    [_storage addAttribute:NSFontAttributeName value:[TweetTextView defaultFont] range:range];
    
}

@end
