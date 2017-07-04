# PullToRefreshView

A simple Swift implementation of a pull-to-refresh control, for use with `UITableView`.

## Basic Use

```swift

// Add the control to the table view, 
// and specify what should be done when it's triggered.

self.tableView.installPullToRefreshViewWithHandler { [weak self] (pullToRefreshView) in

	self?.performSomeLongRunningOperation(input, handler: { (output, error) in
        DispatchQueue.main.async {
            pullToRefreshView.endRefreshing()
        }
    })
}


// To manually trigger the refresh animation.

self.tableView.pullToRefreshView()?.beginRefreshing()

```

### Note

By default, each call to `beginRefreshing()` increments an internal counter, and calling `endRefreshing()` decrements that same counter. This prevents the animation from triggering multiple times if calling `beginRefreshing()` from more than one function in your code.

To force-hide the view, you can call `endRefreshing(force: true)`, which will reset the counter and hide the view, regardless of any unbalanced calls to begin/end refreshing.


## Advanced Use

### Custom UI

A `UIActivityIndicatorView` is used, by default, to mimic `UIRefreshControl`. However, if you would like to customise your UI, you can add subviews to the public `contentView`.

```swift

// Add some custom UI to the content view.
self.tableView.pullToRefreshView()?.contentView.addSubview(self.myCustomView)

// Optionally, hide the default UIActivityIndicatorView.
self.tableView.pullToRefreshView()?.spinnerView.isHidden = true

```

### Animations

You can set your own animation handlers, as follows:

```swift

self.tableView.pullToRefreshView()?.refreshDidStartAnimationHandler = { [weak self] (pullToRefreshView) in
    // Perform some custom animation.
}
        
self.tableView.pullToRefreshView()?.refreshDidStopAnimationHandler = { [weak self] (pullToRefreshView) in
    // Stop your custom animation.
}

```