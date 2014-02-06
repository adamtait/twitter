//
//  TweetDetailViewController.m
//  twitter
//
//  Created by Adam Tait on 2/2/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "TweetView.h"

@interface TweetDetailViewController ()

    // private properties
    @property (nonatomic, strong) Tweet *tweet;
    @property (nonatomic, strong) TweetView *tweetView;

@end

@implementation TweetDetailViewController

- (id)initWithTweet:(Tweet *)tweet
{
    self = [super init];
    if (self) {
        _tweet = tweet;
        self.navigationItem.title = @"tweet";
        
        _tweetView = [[TweetView alloc] initWithFrame:CGRectMake(0, 80, 320, 300)];
        [self.view addSubview:_tweetView];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [_tweetView updateContentWithTweet:_tweet];
    [self.view sendSubviewToBack:_tweetView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
