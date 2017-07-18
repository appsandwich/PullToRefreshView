//
//  PullToRefreshView.swift
//  PullToRefreshView
//
//  Created by Vinny Coyne on 21/04/2017.
//  Copyright © 2017 App Sandwich Limited. All rights reserved.
//

import UIKit

public class PullToRefreshView: UIView, UIGestureRecognizerDelegate {
    
    private weak var tableView: UITableView? = nil
    private var performingReset: Bool = false
    private var insetsLocked: Bool = false
    internal var touchesActive: Bool = false
    private var refreshActivityCount: Int = 0
    static var ptrViewHeight: CGFloat = 80.0
    
    public var contentView: UIView
    public var spinnerView: UIActivityIndicatorView
    
    internal var refreshDidStartHandler: ((PullToRefreshView) -> Void)? = nil
    
    public var refreshDidStartAnimationHandler: ((PullToRefreshView) -> Void)? = nil
    public var refreshDidStopAnimationHandler: ((PullToRefreshView) -> Void)? = nil
    
    override init(frame: CGRect) {
        
        self.contentView = UIView(frame: frame)
        
        self.spinnerView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.spinnerView.hidesWhenStopped = false
        self.contentView.addSubview(self.spinnerView)
        
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        self.refreshDidStartHandler = nil
        self.refreshDidStopAnimationHandler = nil
        self.refreshDidStartAnimationHandler = nil
        
        guard let tv = self.tableView else {
            return
        }
        
        tv.removeObserver(self, forKeyPath: #keyPath(UITableView.contentOffset))
        
        self.tableView = nil
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.addSubview(self.contentView)
        
        self.tableView = nil
        
        guard let tv = self.superview, tv is UITableView else {
            return
        }
        
        self.tableView = tv as? UITableView
        
        self.installObservers()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        guard let tv = self.tableView else {
            return
        }
        
        self.bounds = CGRect(x: 0.0, y: 0.0, width: tv.bounds.width, height: self.bounds.height)
        self.contentView.frame = CGRect(x: 0.0, y: 0.0, width: tv.bounds.width, height: self.bounds.height)
        self.spinnerView.center = CGPoint(x: self.contentView.bounds.width / 2.0, y: self.contentView.bounds.height / 2.0)
    }
    
    // MARK: - Private
    
    private func handleScrollToOffset(_ offset: CGPoint) {
        
        guard offset.y < 0.0 else {
            return
        }
        
        let absoluteOffset = abs(offset.y)
        
        let ratio = absoluteOffset / self.bounds.height
        
        self.contentView.alpha = ratio > 1.0 ? 1.0 : ratio
        
        self.contentView.layer.transform = CATransform3DMakeScale(ratio, ratio, 1.0)
        
        guard self.touchesActive == false, self.insetsLocked == false, absoluteOffset > self.bounds.height else {
            return
        }
        
        self.spinnerView.startAnimating()
        
        self.insetsLocked = self.lockTableViewInsets()
        
        if let handler = self.refreshDidStartHandler {
            handler(self)
        }
        
        if let animationHandler = self.refreshDidStartAnimationHandler {
            animationHandler(self)
        }
    }
    
    // MARK: Insets
    
    private func lockTableViewInsets() -> Bool {
        
        guard let tv = self.tableView else {
            return false
        }
        
        tv.contentInset.top = self.bounds.height
        
        return true
    }
    
    private func resetTableViewInsets() {
        
        self.insetsLocked = false
        
        guard let tv = self.tableView else {
            return
        }
        
        let rect = CGRect(x: 0.0, y: tv.bounds.height, width: 1.0, height: 1.0)
        self.performingReset = true
        tv.scrollRectToVisible(rect, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            
            guard self.refreshActivityCount == 0 else {
                return
            }
            
            tv.contentInset.top = 0.0
            self.performingReset = false
        }
    }
    
    // MARK: Balance start/end refresh calls.
    
    private func incrementRefreshActivity() -> Int {
        
        self.refreshActivityCount += 1
        
        return self.refreshActivityCount
    }
    
    private func decrementRefreshActivity() -> Int {
        
        guard self.refreshActivityCount > 0 else {
            return 0
        }
        
        self.refreshActivityCount -= 1
        
        return self.refreshActivityCount
    }
    
    private func resetRefreshActivities() {
        self.refreshActivityCount = 0
    }
    
    // MARK: KVO
    
    private func installObservers() {
        
        guard let tv = self.tableView else {
            return
        }

        tv.addObserver(self, forKeyPath: #keyPath(UITableView.contentOffset), options: [.new], context: nil)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard self.performingReset == false, self.tableView != nil else {
            return
        }
        
        if keyPath == #keyPath(UITableView.contentOffset) {
            
            if let dict = change {
                
                if let newPoint = dict[NSKeyValueChangeKey.newKey], newPoint is CGPoint {
                    
                    let offset = newPoint as! CGPoint
                    self.handleScrollToOffset(offset)
                }
            }
        }
    }
    
    // MARK: - Pan gesture delegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Public
    
    public func beginRefreshing() {
        
        if 1 == self.incrementRefreshActivity() {
            
            self.insetsLocked = self.lockTableViewInsets()
            
            self.tableView?.setContentOffset(CGPoint(x: 0.0, y: -PullToRefreshView.ptrViewHeight), animated: true)
            
            self.spinnerView.startAnimating()
            
            if let animationHandler = self.refreshDidStartAnimationHandler {
                animationHandler(self)
            }
        }
    }
    
    public func endRefreshing(force: Bool = false) {
        
        if force {
            self.refreshActivityCount = 1
        }
        
        if 0 == self.decrementRefreshActivity() {
            
            self.resetTableViewInsets()
            
            self.spinnerView.stopAnimating()
            
            if let animationHandler = self.refreshDidStopAnimationHandler {
                animationHandler(self)
            }
        }
    }
    
    // MARK: - Class methods

    class func pullToRefreshView() -> PullToRefreshView {
        return PullToRefreshView(frame: CGRect(x: 0.0, y: -self.ptrViewHeight, width: UIScreen.main.bounds.width, height: self.ptrViewHeight))
    }
}

// MARK: - UITableView extensions

extension UITableView {
    
    public func installPullToRefreshViewWithHandler(_ handler: ((PullToRefreshView) -> Void)?) {
        
        guard self.pullToRefreshView() == nil else {
            self.pullToRefreshView()?.refreshDidStartHandler = handler
            return
        }
        
        let pullToRefreshView = PullToRefreshView.pullToRefreshView()
        pullToRefreshView.refreshDidStartHandler = handler
        self.addSubview(pullToRefreshView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(UITableView.handlePTRPanGesture(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        panGesture.delegate = pullToRefreshView
        self.addGestureRecognizer(panGesture)
    }
    
    public func pullToRefreshView() -> PullToRefreshView? {
        
        var pullToRefreshView: PullToRefreshView? = nil
        
        pullToRefreshView = self.subviews.first(where: { (subview) -> Bool in
            return subview is PullToRefreshView
        }) as? PullToRefreshView
        
        return pullToRefreshView
    }
    
    func handlePTRPanGesture(_ panGesture: UIPanGestureRecognizer) {
        
        switch panGesture.state {
        case .began:
            fallthrough
        case .changed:
            self.pullToRefreshView()?.touchesActive = true
            break
            
        case .cancelled:
            fallthrough
        case .failed:
            fallthrough
        case .ended:
            fallthrough
        case .possible:
            self.pullToRefreshView()?.touchesActive = false
            break
        }
    }
}
