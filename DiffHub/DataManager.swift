//
//  DataManager.swift
//  DiffHub
//
//  Created by Hang Liang on 12/10/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import Foundation
import RealmSwift

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
    
    func writePull(pull : Pull) -> Bool {
        guard let realm = self.getRealm() else {
            return false
        }
        
        do {
            try realm.write {
                
                realm.add(pull, update: true)
            }
            
        } catch {
            return false
        }
        
        return true
    }
    
}
