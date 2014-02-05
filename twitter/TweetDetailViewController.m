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
    @property int heightOfFooterLine;

    // private methods <UIResponder>
    - (void)tweetActions:(UITapGestureRecognizer *)recognizer;

@end

@implementation TweetDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (id)initWithTweet:(Tweet *)tweet
{
    self = [super init];
    if (self) {
        _tweet = tweet;
        _heightOfFooterLine = 260;
        self.navigationItem.title = @"tweet";
        
        _tweetView = [[TweetView alloc] initWithFrame:CGRectMake(0, 80, 320, (_heightOfFooterLine - 80))];
        [self.view addSubview:_tweetView];
        
        // add gesture recognizers
        [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tweetActions:)]];
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


#pragma UIResponder methods

- (void)tweetActions:(UITapGestureRecognizer *)recognizer
{
//    int yPositionOfContent;
//    if (_tweet.retweeted) {
//        yPositionOfContent = [TweetView defaultContentFrameWithRetweetHeader].origin.y;
//    } else {
//        yPositionOfContent = [TweetView defaultContentFrame].origin.y;
//    }
//    int height = yPositionOfContent + [_tweetView.content getLayoutHeight] + 25;
    CGPoint p = [recognizer locationInView:self.view];
    
    CGRect replyAction = CGRectMake(40, _heightOfFooterLine, 16, 16);
    CGRect retweetAction = CGRectMake((40+16+25), _heightOfFooterLine, 16, 16);
    CGRect favoriteAction = CGRectMake((40+16+25+16+25), _heightOfFooterLine, 16, 16);
    
    if (CGRectContainsPoint(replyAction, p))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"replyToTweet" object:self.tweet];
    }
    else if (CGRectContainsPoint(retweetAction, p))
    {
        if (!_tweetView.hasBeenRetweeted) {
            [_tweetView setRetweeted];
            [self.tweet createRetweet];
        }
    }
    else if (CGRectContainsPoint(favoriteAction, p))
    {
        [_tweetView setFavorited:!_tweetView.hasBeenFavorited];
        [self.tweet toggleFavorite];
    }
}


@end
