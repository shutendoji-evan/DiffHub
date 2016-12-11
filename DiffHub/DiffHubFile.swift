//
//  DiffHubFile.swift
//  DiffHub
//
//  Created by Hang Liang on 12/11/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import Foundation
import RealmSwift

class DiffFile: Object {

    dynamic var startIndex : Int = 0
    dynamic var endIndex : Int = 0
    dynamic var title : String = ""
    dynamic var pullRequestId : Int = 0
    dynamic var id : String = ""
    dynamic var mode = ""
    
    let sections = List<FileSection>()
    
    func parseSource(sourceStr : String) -> String {
        
        let sourceStr = sourceStr as NSString
        return sourceStr.substring(with: NSRange(location: self.startIndex, length: self.endIndex))
        
    }
    
    func parseSections(sourceStr : String) {
        
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

class FileSection : Object {
    
    dynamic var startIndex : Int = 0
    dynamic var endIndex : Int = 0
    
    dynamic var title = ""
    dynamic var id = ""
    
    //dynamic var oldSection =
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
