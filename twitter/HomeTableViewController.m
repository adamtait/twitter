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


static NSString * const cellIdentifier = @"TweetCell";

@interface HomeTableViewController ()

    // private propeties
    @property (nonatomic, strong) NSMutableArray *tweets;

    // private methods
    - (void)reload:(id)sender;
    - (void)signOut:(id)sender;
    - (void)newTweet:(id)sender;
    - (void)afterNewTweet:(id)sender;
    - (void)replyToTweet:(id)sender;
    - (void)didSelectTweet:(id)sender;

@end

@implementation HomeTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        [self reload:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // setup the UITableView delegate to be this UITableViewController
    [self.tableView setDelegate:self];
    
    // register the TodoCell class for the reuseIdentifier
    [[self tableView] registerClass:[TweetCell class] forCellReuseIdentifier:cellIdentifier];
    
    // setup navigation bar
    self.navigationItem.title = @"home";
    
    [self.navigationController.navigationBar setBarTintColor:[Color twitterBlue]];
    self.navigationController.navigationBar.tintColor = [Color fontWhite];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [Color fontWhite]}];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"sign out" style:UIBarButtonItemStylePlain target:self action:@selector(signOut:)];
    [self.navigationItem setLeftBarButtonItem:leftBarButton];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"new" style:UIBarButtonItemStylePlain target:self action:@selector(newTweet:)];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterNewTweet:) name:@"newTweet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replyToTweet:) name:@"replyToTweet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectTweet:) name:@"tweetWasSelected" object:nil];
    
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
    // cell re-use becomes a problem some cells are retweet cells, and others are not
    // it's easier to just re-create the cell everytime (yes, this is a hack)
    static NSString *CellIdentifier = @"Cell";
    TweetCell *cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    if (indexPath.row > ([_tweets count] - 10)) {
        // to handle infinite scrolling, let's load more tweets
        int indexOfLastLoadedTweet = [_tweets count] - 1;
        Tweet *lastLoadedTweet = _tweets[indexOfLastLoadedTweet];
        [[TwitterClient instance] homeTimelineWithCount:50 sinceId:nil maxId:lastLoadedTweet.idStr
                                                success:^(AFHTTPRequestOperation *operation, id response) {
                                                    
                                                    [_tweets addObjectsFromArray:[Tweet tweetsWithArray:response]];
                                                    [self.tableView reloadData];
                                                    
                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    // TODO handle network error
                                                }];
    }
    
    [cell updateContentWithTweet:_tweets[indexPath.row]];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

- (void) didSelectTweet:(id)sender
{
    NSNotification *notification = (NSNotification *)sender;
    Tweet *tweet = notification.object;
    
    NSLog(@"about to load Detail controller with text / %@ /", tweet.text);
    
    TweetDetailViewController *tweetDetailViewController = [[TweetDetailViewController alloc] initWithTweet:tweet];
    [self.navigationController pushViewController:tweetDetailViewController animated:YES];
}



- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetTextView *fakeTextView = [[TweetTextView alloc] init];
    Tweet *tweet = _tweets[indexPath.row];
    [fakeTextView updateContentWithString:tweet.text];    // setAttributedText:[[NSAttributedString alloc] initWithString:[_todoList getStringForIndex:indexPath.row]]
    
    if (tweet.retweeted) {
        return (5 + 16) + [TweetView defaultContentFrame].origin.y + [fakeTextView getLayoutHeightForWidth:275.0] + 35;
    } else {
        return [TweetView defaultContentFrame].origin.y + [fakeTextView getLayoutHeightForWidth:275.0] + 35;
    }
}


#pragma private methods

- (void)reload:(id)sender
{
    NSLog(@"attempting to reload all tweet data");
    [[TwitterClient instance] homeTimelineWithCount:50 sinceId:nil maxId:nil
                                            success:^(AFHTTPRequestOperation *operation, id response) {
        self.tweets = [Tweet tweetsWithArray:response];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // TODO handle network error
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


@end
