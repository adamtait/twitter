//
//  HomeTableViewController.m
//  twitter
//
//  Created by Adam Tait on 1/29/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import "HomeTableViewController.h"
#import "NewTweetViewController.h"
#import "TweetDetailViewController.h"
#import "Color.h"
#import "TweetCell.h"
#import "User.h"
#import "TwitterClient.h"
#import "Tweet.h"
#import "TweetTextView.h"
#import "TweetView.h"
#import "SVProgressHUD.h"


static NSString * const cellIdentifier = @"TweetCell";

@interface HomeTableViewController ()

    // private propeties
    @property (nonatomic, strong) NSMutableArray *tweets;
    @property (atomic, assign) BOOL tweetLoadingStarted;

    // private methods
    - (void)reload:(id)sender;
    - (void)signOut:(id)sender;
    - (void)newTweet:(id)sender;
    - (void)afterNewTweet:(id)sender;
    - (void)replyToTweet:(id)sender;
    - (void)handleInfiniteScrollGivenIndex:(int)index;

@end

@implementation HomeTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self reload:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tweetLoadingStarted = NO;

    // setup the UITableView delegate to be this UITableViewController
    [self.tableView setDelegate:self];
    
    // register the TweetCell class for the reuseIdentifier
    [[self tableView] registerClass:[TweetCell class] forCellReuseIdentifier:cellIdentifier];
    
    // setup navigation bar
    self.navigationItem.title = @"home";
    [self.navigationController.navigationBar setBarTintColor:[Color twitterBlue]];
    self.navigationController.navigationBar.tintColor = [Color fontWhite];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[Color fontWhite]}];
    
    // setup navigation bar items
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"sign out" style:UIBarButtonItemStylePlain target:self action:@selector(signOut:)];
    [self.navigationItem setLeftBarButtonItem:leftBarButton];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"new" style:UIBarButtonItemStylePlain target:self action:@selector(newTweet:)];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
    // handle events from subviews
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterNewTweet:) name:@"newTweet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replyToTweet:) name:@"replyToTweet" object:nil];
    
    // handle pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    [self handleInfiniteScrollGivenIndex:(int)indexPath.row];
    
    [cell updateContentWithTweet:_tweets[indexPath.row]];
    return cell;
}


#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView
willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet *tweet = _tweets[indexPath.row];
    TweetDetailViewController *tweetDetailViewController = [[TweetDetailViewController alloc] initWithTweet:tweet];
    
    [self.navigationController pushViewController:tweetDetailViewController animated:YES];
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetTextView *fakeTextView = [[TweetTextView alloc] init];
    Tweet *tweet = _tweets[indexPath.row];
    [fakeTextView updateContentWithString:tweet.text];
    
    if (tweet.retweeted) {
        return (5 + 16) + [TweetView defaultContentFrame].origin.y + [fakeTextView getLayoutHeightForWidth:275.0] + 35;
    } else {
        return [TweetView defaultContentFrame].origin.y + [fakeTextView getLayoutHeightForWidth:275.0] + 35;
    }
}


#pragma private methods

- (void)reload:(id)sender
{
    [[TwitterClient instance] homeTimelineWithCount:50 sinceId:nil maxId:nil
                                            success:^(AFHTTPRequestOperation *operation, id response) {
                                                
                                                self.tweets = [Tweet tweetsWithArray:response];
                                                [self.tableView reloadData];
                                                [self.refreshControl endRefreshing];
                                                
                                            }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                
                                                [self.refreshControl endRefreshing];
                                                _tweetLoadingStarted = NO;
                                                [SVProgressHUD showErrorWithStatus:@"network error"];
                                                
                                            }];
}


- (void)signOut:(id)sender
{
    [User setCurrentUser:nil];
}

- (void)newTweet:(id)sender
{
    [self.navigationController pushViewController:[[NewTweetViewController alloc] init] animated:YES];
}

- (void)afterNewTweet:(id)sender
{
    NSNotification *notification = (NSNotification *)sender;
    Tweet *tweet = notification.object;
    [_tweets insertObject:tweet atIndex:0];
    [self.tableView reloadData];
}

- (void)replyToTweet:(id)sender
{
    NSNotification *notification = (NSNotification *)sender;
    Tweet *tweet = notification.object;
    NewTweetViewController *newTweetViewController = [[NewTweetViewController alloc] init];
    newTweetViewController.prefilledText = [NSString stringWithFormat:@"%@ ", tweet.userhandle];
    [self.navigationController pushViewController:newTweetViewController animated:YES];
}

- (void)handleInfiniteScrollGivenIndex:(int)index
{
    if (index > ([_tweets count] - 10) && !_tweetLoadingStarted) {
        
        int indexOfLastLoadedTweet = (int)[_tweets count] - 1;
        Tweet *lastLoadedTweet = _tweets[indexOfLastLoadedTweet];
        
        // provide synchonization & remove possibility that many requests are made at the same time
        _tweetLoadingStarted = YES;
        
        [[TwitterClient instance] homeTimelineWithCount:50 sinceId:nil maxId:lastLoadedTweet.idStr
                                                success:^(AFHTTPRequestOperation *operation, id response) {
                                                    
                                                    [_tweets addObjectsFromArray:[Tweet tweetsWithArray:response]];
                                                    [self.tableView reloadData];
                                                    _tweetLoadingStarted = NO;
                                                    
                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    
                                                    _tweetLoadingStarted = NO;
                                                    [SVProgressHUD showErrorWithStatus:@"network error"];
                                                    
                                                }];
    }
}


@end
