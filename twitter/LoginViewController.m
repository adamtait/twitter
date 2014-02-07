//
//  LoginViewController.m
//  twitter
//
//  Created by Adam Tait on 1/30/14.
//  Copyright (c) 2014 Adam Tait. All rights reserved.
//

#import "LoginViewController.h"
#import "Color.h"
#import "TwitterClient.h"
#import "User.h"
#import "SVProgressHUD.h"

@interface LoginViewController ()

    // private properties
    @property (weak, nonatomic) IBOutlet UIButton *loginButton;

    // private methods
    - (IBAction)onLoginButton:(id)sender;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loginButton.backgroundColor = [Color twitterBlue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma private methods

- (IBAction)onLoginButton:(id)sender {
    [[TwitterClient instance] authorizeWithCallbackUrl:[NSURL URLWithString:@"adamtait-twitter://success"]
                                               success:^(AFOAuth1Token *accessToken, id responseObject) {
                                                   [[TwitterClient instance] currentUserWithSuccess:^(AFHTTPRequestOperation *operation, id response) {
                                                       [User setCurrentUser:[[User alloc] initWithDictionary:response]];
                                                   }];
                                               } failure:^(NSError *error) {
                                                   [SVProgressHUD showErrorWithStatus:@"network error"];
                                               }];
}

@end
