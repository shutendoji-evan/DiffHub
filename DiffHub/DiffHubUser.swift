//
//  DiffHubUser.swift
//  DiffHub
//
//  Created by Hang Liang on 12/10/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import Foundation
import RealmSwift

class User : Object {
    
    dynamic var id : Int = 0
    dynamic var login : String = ""
    dynamic var avatar_url : String = ""

    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
