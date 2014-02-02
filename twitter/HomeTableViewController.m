//
//  HomeTableViewController.m
//  twitter
//
//  Created by Adam Tait on 1/29/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import "HomeTableViewController.h"
#import "NewTweetViewController.h"
#import "Color.h"
#import "TweetCell.h"
#import "User.h"
#import "TwitterClient.h"
#import "Tweet.h"
#import "TweetTextView.h"


static NSString * const cellIdentifier = @"TweetCell";

@interface HomeTableViewController ()

    // private propeties
    @property (nonatomic, strong) NSMutableArray *tweets;

    // private methods
    - (void)reload;
    - (void)signOut:(id)sender;
    - (void)newTweet:(id)sender;
    - (void)afterNewTweet:(id)sender;

@end

@implementation HomeTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        [self reload];
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
    //    navigationController.navigationBar.barTintColor = [Color twitterBlue];
    self.navigationController.navigationBar.tintColor = [Color fontWhite];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [Color fontWhite]}];
//    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"sign out" style:UIBarButtonItemStylePlain target:self action:@selector(signOut:)];
    [self.navigationItem setLeftBarButtonItem:leftBarButton];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"new" style:UIBarButtonItemStylePlain target:self action:@selector(newTweet:)];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterNewTweet:) name:@"newTweet" object:nil];
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
    static NSString *CellIdentifier = @"Cell";
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */


- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetTextView *fakeTextView = [[TweetTextView alloc] initWithFrame:[TweetCell defaultContentFrame]];
    Tweet *tweet = _tweets[indexPath.row];
    [fakeTextView updateContentWithString:tweet.text];    // setAttributedText:[[NSAttributedString alloc] initWithString:[_todoList getStringForIndex:indexPath.row]]
    
    return [TweetCell defaultContentFrame].origin.y + [fakeTextView getLayoutHeight] + 25;
}


#pragma private methods

- (void)reload
{
    [[TwitterClient instance] homeTimelineWithCount:50 sinceId:0 maxId:0
                                            success:^(AFHTTPRequestOperation *operation, id response) {
        self.tweets = [Tweet tweetsWithArray:response];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Do nothing
    }];
}


- (void)signOut:(id)sender
{
    // TODO delete User
    // set self.window.rootViewController to LoginViewController
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


@end
