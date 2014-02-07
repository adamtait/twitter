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
While I do like the portability and re-usability of layouts in code, I think it can be quicker and easier to use interface builder. Interface builder has the constraint issue resolution tool which is a major advantage.


#### NSLayoutConstraints & [UIView initWithFrame]

I had to learn constraints to handle the layout of the items in each tweet cell correctly. However, I started out by using [UIView initWithFrame] to layout the components. Starting out, I made a number of bad assumptions about the placement and sizes the UITextView. These assumptions turned out to be bad and weren't very easy to remove.
I rebuilt the UITextView using constraints for the layout. Using constraints solved problems with TweetCell layout, heightForCellAtIndexPath calculations in HomeTableViewController and layout of the TweetDetailViewController.

In using NSLayoutConstraints, I started by using [NSLayoutConstraint constraintWithVisualFormat] which is much easier to read than [NSLayoutConstraints constraintWithItem]. I converted some to constraintWithItem because it's easier to compose similar constraints with varying components or values. I have found that in cases where you want to build contraints relating more than 2 UIViews, then [constraintWithVisualFormat] is the way to go. If you only need set width or height constraints or relate 2 UIViews, then [constraintWithItem] is your friend.


#### no reusable cells makes UITableView scrolling slow

Not using the UITableView's reusable cells was a hack to get around all the issues that arose when reusing a cell with a different layout. Specifically, the retweet header got re-used for a cell without a retweet; it would look ugly and the height calculations would be off. By fixing the mixture of hard coded frames & constraints (discussed above in NSLayoutConstraints), and adding a `[TweetCell clearUnused subviews]` I was able to solve that probelm.
The scrolling in the app is noticably smoother & quicker with the reusable cells.


#### OAuth1 & AFNetworking

Twitter doesn't currently support the OAuth2 spec, so we can connect only using OAuth1. AFNetworking 2.0 does not support the AFOAuth1Client, so (@timothy1ee, who wrote the OAuth code I'm using) was forced to use AFNetworking1.3 instead. I could have updated AFNetworking to 2.0 and use BDBOAuth1Client instead, but decided just to stick with the provided code.


#### handling touch events

I wanted to handle the touch events on the UIImageViews themselves (the reply, retweet & favorite buttons), but couldn't get the UIGestureRecognizer to fire on my delegate UITableCellView. Instead, I chose to capture all gesture events on the entire cell then calculate the area for the clicked button.
This became even more difficult when I wanted to handle the selection of the cell to load the TweetDetailViewController. I had to handle the TweetCell selection through message passing from the handler in the TweetCell.


#### TweetView heirarchy

I decided to separate the creation & setup of TweetCell subviews into a separate class for portability; I wanted to re-use the code in the Detail View. But, the Detail View is slightly different; the layout of the same components is different and there are additional subviews to add.
I subclassed TweetView into ShortTweetView & FullTweetView, to be used by the TweetCell and DetailView, respectively. This allowed me to share much of the setup & organization, while still offering each it's own layout & unique behavior.
This view heirarchy was great when I wanted to add the updating of retweet and favorite counts on a click of the favorite & retweet buttons. I could just override the superclass's default setRetweet & setFavorited methods, call the superclass's implementation and add the child class's extra `updateCountLabelsWithTweet` method.

```ObjectiveC
- (void)setRetweeted:(BOOL)retweeted
{
    [super setRetweeted:retweeted];
	[self updateCountLabelsWithTweet:super.tweet];
}
```


#### wrapping HTTP requests in a synchonous mutex block


I decided to solve infinite scrolling by loading a new set of tweets and appending them to the TableViewDataSource, an array of tweets the TableViewController was holding a reference to. To fire the request, I peeked at the index of the cell being loaded by the UITableView. I checked that the index was within a range.
The problem with this approach is that it will cause many requests to be fired at once. All you have to do is scroll fast enough, most cells in that range will be loaded and for each one a new request will be fired.
The solution I used was to create an atomic class property to synchonize the new HTTP request initiation block between threads (or at least UITableViewDelegate requests for new cells).
This was my first foray into asynchronous programming in ObjectiveC. It was really easy, actually.
