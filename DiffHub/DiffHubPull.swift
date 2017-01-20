//
//  DiffHubPull.swift
//  DiffHub
//
//  Created by Hang Liang on 12/10/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import Foundation
import RealmSwift

class Pull : Object {
    
    dynamic var id : Int = 0
    dynamic var number : Int = 0
    dynamic var url : String = ""
    dynamic var diff_url : String = ""
    dynamic var state : String = ""
    dynamic var title : String = ""
    dynamic var body : String = ""
    dynamic var creationDate : String = ""
    dynamic var sinceNow : String = ""
    dynamic var updatedDate : String = ""
    dynamic var diffFileDir : String = ""
    dynamic var belongsTo : String = ""
    
    dynamic var user : User?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
