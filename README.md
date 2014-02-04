twitter
=======

a simple twitter client for iOS


## Usage

When you first open the app, you should sign in with your Twitter account using OAuth.

![splash screen](https://dl.dropboxusercontent.com/u/3992486/app_screenshots/twitter/sign_in.png)
![Twitter OAuth page](https://dl.dropboxusercontent.com/u/3992486/app_screenshots/twitter/twitter_oauth_page.png)

check out your current tweet stream

![home view controller](https://dl.dropboxusercontent.com/u/3992486/app_screenshots/twitter/home_view_controller.png)

reply to a tweet or add a new one

![reply to a tweet](https://dl.dropboxusercontent.com/u/3992486/app_screenshots/twitter/reply_tweet.png)



## Architecture Decision Records (ADRs)

[Haven't heard of an ADR before?](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions)

This simple twitter client is built with mostly vanilla iOS UIKit components.

#### no storyboard, and select uses of interface builder

Now that I'm more comfortable defining, composing and handling UIView subclasses in code, using interface builder seems like a bit of a pain. The limited opportunities to connect or view settings for components gives a slight advantage to layouts in code.

#### NSLayoutConstraints & [UIView initWithFrame]

I had to learn constraints to handle the layout of the items in each tweet cell correctly. However, I started out by using [UIView initWithFrame] to layout the components. Starting out, I made a number of bad assumptions about the placement and sizes the UITextView. These assumptions turned out to be bad and weren't very easy to remove.
If this was done correctly, the UITextView should also have been laid out with constraints. This would have solved problems with TweetCell layout, heightForCellAtIndexPath calculations in HomeTableViewController and layout of the TweetDetailViewController.

In using NSLayoutConstraints, I started by using [NSLayoutConstraint constraintWithVisualFormat] which is much easier to read than [NSLayoutConstraints constraintWithItem]. I converted some to constraintWithItem because it's easier to compose similar constraints with varying components or values. 


#### no reusable cells

Not using the UITableView's reusable cells was a hack to get around all the issues that arose when reusing a cell with a different layout. If a cell that was built with a retweet header got re-used for a cell without a retweet, the old retweet details would remain and the height calculations would be off. By fixing the mixture of hard coded frames & constraints (discussed above in NSLayoutConstraints), and adding a `[TweetCell clearUnused subviews]` this problem could have been resolved.
The scrolling in the app feels slow and jittery without the reusable cells.


#### OAuth1 & AFNetworking

Twitter doesn't currently support the OAuth2 spec, so we can connect only using OAuth1. AFNetworking 2.0 does not support the AFOAuth1Client, so (@timothy1ee, who wrote the OAuth code I'm using) was forced to use AFNetworking1.3 instead. I could have updated AFNetworking to 2.0 and use BDBOAuth1Client instead, but decided just to stick with the provided code.


#### handling touch events

I wanted to handle the touch events on the UIImageViews themselves (the reply, retweet & favorite buttons), but couldn't get the UIGestureRecognizer to fire on my delegate UITableCellView. Instead, I chose to capture all gesture events on the entire cell then calculate the area for the clicked button.
This became even more difficult when I wanted to handle the selection of the cell to load the TweetDetailViewController. I had to handle the TweetCell selection through message passing from the handler in the TweetCell. 


