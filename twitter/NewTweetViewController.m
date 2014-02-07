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
#import "Color.h"

@interface NewTweetViewController ()

    @property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
    @property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
    @property (weak, nonatomic) IBOutlet UILabel *userhandleLabel;
    @property (weak, nonatomic) IBOutlet UITextView *editableText;
    @property (nonatomic, strong) UILabel *characterCountLabel;
    @property (nonatomic, strong) UIBarButtonItem *tweetButton;

    // private instance methods
    - (void)sendTweet:(id)sender;

@end

@implementation NewTweetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _prefilledText = nil;
        
        _characterCountLabel = [TweetView setupLabelWithFont:[UIFont systemFontOfSize:14] textColor:[Color fontGray]];
        _characterCountLabel.text = @"140";
        [_characterCountLabel sizeToFit];

        _tweetButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain
                                                       target:self action:@selector(sendTweet:)];
        [_tweetButton setEnabled:NO];
        UIBarButtonItem *characterCountItem = [[UIBarButtonItem alloc] initWithCustomView:_characterCountLabel];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:_tweetButton, characterCountItem, nil]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TweetView loadImageFromUrl:[User currentUser].profileImageURL imageView:_profileImageView];
    _usernameLabel.text = [User currentUser].username;
    _userhandleLabel.text = [User currentUser].userhandle;
    
    if (_prefilledText) {
        _editableText.text = _prefilledText;
        _characterCountLabel.text = [NSString stringWithFormat:@"%lu", ([_characterCountLabel.text intValue] - [_editableText.text length])];
    }
    _editableText.keyboardType = UIKeyboardTypeTwitter;
    _editableText.delegate = self;
    [_editableText becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView
{
    int remainingCharacterCount = 140 - (int)[_editableText.text length];
    _characterCountLabel.text = [NSString stringWithFormat:@"%d", remainingCharacterCount];

    if ((remainingCharacterCount > 0) && (remainingCharacterCount < 20)) {
        _characterCountLabel.textColor = [Color fontYellow];
    } else if ((remainingCharacterCount < 0) || (remainingCharacterCount == (140 - [_prefilledText length]))) {
        if (remainingCharacterCount < 0) {
            _characterCountLabel.textColor = [Color fontRed];
        }
        [_tweetButton setEnabled:NO];
    } else {
        _characterCountLabel.textColor = [Color fontGray];
        [_tweetButton setEnabled:YES];
    }
}


#pragma private instance methods

- (void)sendTweet:(id)sender
{
    [[TwitterClient instance] updateStatusWithString:_editableText.text];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newTweet" object:[[Tweet alloc] initWithString:_editableText.text]];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
