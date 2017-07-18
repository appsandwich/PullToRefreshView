//
//  ViewController.swift
//  PullToRefreshViewDotSwift
//
//  Created by vinny.coyne on 07/18/2017.
//  Copyright (c) 2017 vinny.coyne. All rights reserved.
//

import UIKit
import PullToRefreshViewDotSwift

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.installPullToRefreshViewWithHandler { [weak self] (ptrView) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                
                self?.tableView.pullToRefreshView()?.endRefreshing()
                
                self?.tableView.reloadData()
            })
        }
        
        self.tableView.pullToRefreshView()?.refreshDidStartAnimationHandler = { [weak self] (ptrView) in
            
            UIView.animate(withDuration: 0.1, animations: {
                self?.tableView.backgroundColor = .red
            })
        }
        
        self.tableView.pullToRefreshView()?.refreshDidStopAnimationHandler = { [weak self] (ptrView) in
            
            UIView.animate(withDuration: 0.1, animations: {
                self?.tableView.backgroundColor = .green
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.textLabel?.text = "Row \(indexPath.row)"
    }
    
    // MARK: - Table view delegate & data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = "cellID"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) else {
            
            let newCell = UITableViewCell(style: .default, reuseIdentifier: cellID)
            self.configureCell(newCell, at: indexPath)
            
            return newCell
        }
        
        self.configureCell(cell, at: indexPath)
        
        return cell
    }
}

