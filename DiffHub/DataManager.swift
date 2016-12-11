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

class DataManager {
    
    static let sharedInstance : DataManager = {
        let instance = DataManager()
        return instance
    }()
    
    func getRealm() -> Realm? {
        guard let realm = try? Realm() else {
            return nil
        }
        
        return realm
    }
    
    func getPulls() -> Results<Pull>? {
        guard let realm = self.getRealm() else {
            return nil
        }
        
        return realm.objects(Pull.self)
    }
    
    func writePull(pullJSON : JSON) {
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
    
    func writeFilesIntoPull(pull: Pull) {
        guard let realm = self.getRealm() else {
            return
        }
        do {
            try realm.write {
                let files = realm.objects(DiffFile.self).filter("pullRequestId = \(pull.id)")
                pull.files.append(objectsIn: files)
                
            }
            
        } catch {
            print("write files into: #\(pull.number) failed.")
        }
    }
    
    func writeDiffFile(diffFile: DiffFile) {
        guard let realm = self.getRealm() else {
            return
        }
        
        do {
            try realm.write {
                realm.add(diffFile, update: true)
            }
        } catch {
            print("write diffFile failed")
            return
        }
    }
}
