//
//  DataManager.swift
//  DiffHub
//
//  Created by Hang Liang on 12/10/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

struct DataManager {
    
    static func getRealm() -> Realm? {
        guard let realm = try? Realm() else {
            return nil
        }
        
        return realm
    }
    
    static func getPulls() -> Results<Pull>? {
        guard let realm = self.getRealm() else {
            return nil
        }
        
        return realm.objects(Pull.self)
    }
    
    static func getPull(id : Int) -> Pull? {
        
        guard let realm = DataManager.getRealm() else {
            print("fetch realm failed")
            return nil
        }
        guard let pull = realm.objects(Pull.self).filter("id = \(id)").first else {
            print("Fetch pull failed")
            return nil
        }
        
        return pull
    }
    
    static func writePull(pullJSON : JSON) {
        guard let realm = self.getRealm() else {
            return
        }
        
        for pull in pullJSON {
            
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
                
                //date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                if let date = dateFormatter.date(from: created_at) {
                    let dateNS = date as NSDate
                    pullRequest.sinceNow = dateNS.timeAgoSinceNow().lowercased()
                }
                
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
            
            do {
                try realm.write {
                    
                    realm.add(pullRequest, update: true)
                }
                
            } catch {
                print("write pull: #\(pullRequest.number) into realm failed.")
                continue
            }
        }

    }
    
    static func writeFilePathToPull(filePath: URL, pull: Pull) {
        guard let realm = DataManager.getRealm() else {
            return
        }
        do {
            try realm.write {
                pull.diffFileDir = filePath.absoluteString
            }
            
        } catch {
            print("write pull: #\(pull.number) into realm failed.")
        }
    }
    
}
