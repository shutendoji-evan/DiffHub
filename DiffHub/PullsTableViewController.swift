//
//  PullsTableViewController.swift
//  DiffHub
//
//  Created by Hang Liang on 12/10/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift
import Kingfisher
import AMScrollingNavbar
import DateTools

class PullsTableViewController: UITableViewController {
    
    var pulls : Results<Pull>?
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setupNavBar()

        self.setupTV()
        
        //setup pull refresh
        self.refreshControl?.addTarget(self, action: #selector(PullsTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        //realm changes notification
        self.setupRealmNotification()
        
        self.updatePullRequestsList()

    }
    
    func setupRealmNotification() {
        
        self.pulls = DataManager.getPulls()
        
        self.notificationToken = self.pulls?.addNotificationBlock({ [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else {
                return
            }
            switch changes {
            case .initial:
                self?.tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):

                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
                break
            case .error(let error):
                
                fatalError("\(error)")
                break
            }
        })
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.notificationToken?.stop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let navigationController = navigationController as? ScrollingNavigationController {
            //navigationController.followScrollView(tableView, delay: 50.0)
            navigationController.stopFollowingScrollView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNavBar() {
        self.navigationItem.title = DiffHubConstants.repositoryName
    }
    
    func setupTV() {
        //setup pullRequests tableView
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        self.tableView.register(UINib(nibName: "PullRequestInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "requestCell")
        
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.updatePullRequestsList()
    }

}


extension PullsTableViewController {
    
    // pullRequests tableView delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = self.pulls?.count else {
            return 0
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath) as? PullRequestInfoTableViewCell else {
            return UITableViewCell()
        }
        
        guard let pullData = self.pulls?[indexPath.item] else {
            return cell
        }
        
        cell.pullTitleLabel.text = pullData.title
        
        guard let pullUser = pullData.user else {
            cell.pullDescriptionLabel.text = ""
            return cell
        }
        
        let avatar_url = URL(string: pullUser.avatar_url)
        cell.avatarIV.kf.setImage(with: avatar_url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        
        if pullData.state == "open" {
            cell.pullDescriptionLabel.text = "#\(pullData.number) opened on \(pullData.sinceNow) by \(pullUser.login)"
        }
        else if pullData.state == "close" {
            
        }
        else {
            cell.pullDescriptionLabel.text = "#\(pullData.number)"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.performSegue(withIdentifier: "pullListToSplitFile", sender: indexPath)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "pullListToSplitFile" {

            guard let indexPath = sender as? IndexPath else {
                return
            }
            
            self.tableView.deselectRow(at: indexPath, animated: true)
            
            
            guard let pullData = self.pulls?[indexPath.item] else {
                return
            }
            
            guard let splitVC = segue.destination as? SplitChangesViewController else {
                return
            }
            
            splitVC.pull = pullData
            
        }
    }
}

extension PullsTableViewController {

    //update pulls
    func updatePullRequestsList() {
        Alamofire.request(DiffHubConstants.pullsURL, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { (response) in
                if response.result.isSuccess {
                    guard let data = response.data else {
                        print("Failed fetch pulls")
                        return
                    }
                    
                    self.refreshControl?.endRefreshing()
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        let pullsData = JSON(data: data)
                        DataManager.writePull(pullJSON: pullsData)
                    }

                }
                else {
                    print("Failed request pulls due to \(response.description)")
                }
        }
        
    }
    
}
