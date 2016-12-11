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

class PullsTableViewController: UITableViewController {
    
    var pulls : Results<Pull>?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setupNavBar()
        
        self.getPulls()
        self.setupTV()
        self.updatePullRequestsList()
        
        //setup pull refresh
        self.refreshControl?.addTarget(self, action: #selector(PullsTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)

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
            cell.pullDescriptionLabel.text = "#\(pullData.number) opened on \(pullData.creationDate) by \(pullUser.login)"
        }
        else if pullData.state == "close" {
            
        }
        else {
            cell.pullDescriptionLabel.text = "#\(pullData.number)"
        }
        
        return cell
    }
}

extension PullsTableViewController {
    
    //load pulls from realm
    func getPulls() {
        
        guard let pullResults = DataManager.sharedInstance.getPulls() else {
            print("failed to fetch pulls")
            return
        }
        
        self.pulls = pullResults.sorted(byProperty: "number", ascending: false)
    }
    
    //update pulls
    
    func updatePullRequestsList() {
        Alamofire.request(DiffHubConstants.pullsURL, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { (response) in
                if response.result.isSuccess {
                    guard let data = response.data else {
                        print("Failed fetch pulls")
                        return
                    }
                    
                    let pullsData = JSON(data: data)
                    
                    for pull in pullsData {
                        
                        let pullRequest = Pull()
                        
                        if let id : Int = pull.1["id"].int {
                            pullRequest.id = id
                        }
                        if let number : Int = pull.1["number"].int {
                            pullRequest.number = number
                        }
                        if let url : String = pull.1["url"].string {
                            pullRequest.url = url
                        }
                        if let state : String = pull.1["state"].string {
                            pullRequest.state = state
                        }
                        if let diff_url : String = pull.1["diff_url"].string {
                            pullRequest.diff_url = diff_url
                        }
                        if let title : String = pull.1["title"].string {
                            pullRequest.title = title
                        }
                        if let body : String = pull.1["body"].string {
                            pullRequest.body = body
                        }
                        if let created_at : String = pull.1["created_at"].string {
                            pullRequest.creationDate = created_at
                        }
                        
                        //user
                        if let userDict = pull.1["user"].dictionary {
                            let user = User()
                            if let login : String = userDict["login"]?.string {
                                user.login = login
                            }
                            if let id : Int = userDict["id"]?.int {
                                user.id = id
                            }
                            if let avatar_url : String = userDict["avatar_url"]?.string {
                                user.avatar_url = avatar_url
                            }
                            
                            pullRequest.user = user
                        }
                        
                        if !DataManager.sharedInstance.writePull(pull: pullRequest) {
                            print("write pull: \(pullRequest.number) into realm failed.")
                            continue
                        }
                        
                    }
                    
                    self.getPulls()
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    
                }
                else {
                    print("Failed request pulls due to \(response.description)")
                }
        }
        
    }
}
