//
//  TweetDetailViewController.m
//  twitter
//
//  Created by Adam Tait on 2/2/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "FullTweetView.h"

@interface TweetDetailViewController ()

    // private properties
    @property (nonatomic, strong) Tweet *tweet;
    @property (nonatomic, strong) FullTweetView *tweetView;

@end

@implementation TweetDetailViewController

- (id)initWithTweet:(Tweet *)tweet
{
    self = [super init];
    if (self) {
        _tweet = tweet;
        self.navigationItem.title = @"tweet";
        
        _tweetView = [[FullTweetView alloc] initWithFrame:CGRectMake(0, 0, 300, 700)];
        [self.view addSubview:_tweetView];
        
        // add constraints for tweetView
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tweetView attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0 constant:300]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tweetView attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0 constant:700]];
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-[_tweetView]"
                                   options:0 metrics:nil
                                   views:NSDictionaryOfVariableBindings(_tweetView)]];
        id topGuide = self.topLayoutGuide;
        [self.view addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:@"V:[topGuide]-[_tweetView]"
                                  options:0 metrics:nil
                                  views:NSDictionaryOfVariableBindings(topGuide, _tweetView)]];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [_tweetView updateContentWithTweet:_tweet];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
