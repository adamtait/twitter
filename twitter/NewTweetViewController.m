//
//  NewTweetViewController.m
//  twitter
//
//  Created by Adam Tait on 2/2/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import "NewTweetViewController.h"
#import "User.h"
#import "TweetView.h"
#import "TwitterClient.h"
#import "Tweet.h"

@interface NewTweetViewController ()

    @property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
    @property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
    @property (weak, nonatomic) IBOutlet UILabel *userhandleLabel;
    @property (weak, nonatomic) IBOutlet UITextView *editableText;

    // private instance methods
    - (void)sendTweet:(id)sender;

@end

@implementation NewTweetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _prefilledText = nil;
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(sendTweet:)]];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TODO get TopLayoutGuide constraint working. shouldn't have to guess at the height below the navigation bar
//    NSMutableArray *constraints = [[NSMutableArray alloc] init];
//    NSString *verticalConstraint = @"V:|[v]|";
//    NSMutableDictionary *views = [NSMutableDictionary new];
//    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
//        views[@"topLayoutGuide"] = self.topLayoutGuide;
//        verticalConstraint = @"V:[topLayoutGuide][v]|";
//    }
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraint options:0 metrics:nil views:views]];
//    [self.view addConstraints:constraints];
    
    [TweetView loadImageFromUrl:[User currentUser].profileImageURL imageView:_profileImageView];
    _usernameLabel.text = [User currentUser].username;
    _userhandleLabel.text = [User currentUser].userhandle;
    
    if (_prefilledText) {
        _editableText.text = _prefilledText;
    }
    _editableText.keyboardType = UIKeyboardTypeTwitter;
    [_editableText becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma private instance methods

- (void)sendTweet:(id)sender
{
    [[TwitterClient instance] updateStatusWithString:_editableText.text];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newTweet" object:[[Tweet alloc] initWithString:_editableText.text]];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
