//
//  DiffHubFile.swift
//  DiffHub
//
//  Created by Hang Liang on 12/11/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import Foundation
import RealmSwift

class DiffFile {

    var startIndex : Int = 0
    var endIndex : Int = 0
    var title : String = ""
    var pullRequestId : Int = 0
    //dynamic var id : String = ""
    var mode = ""
    var sourceFileA = ""
    var sourceFileB = ""
    
    var sections = Array<FileSection>()
    var lines = Array<String>()
    
    func parseSource(sourceStr: String) -> String {
        let sourceStr = sourceStr as NSString
        return sourceStr.substring(with: NSRange(location: self.startIndex, length: self.endIndex))
    }

//    override static func primaryKey() -> String? {
//        return "id"
//    }
    
}

class FileSection {
    
    var startIndex : Int = 0
    var endIndex : Int = 0
    
    var title = ""
    var lines = 0
    var sectionSource = Array<String>()
    
    func parseSource(sourceStr: String) -> String {
        let sourceStr = sourceStr as NSString
        return sourceStr.substring(with: NSRange(location: self.startIndex, length: self.endIndex))
    }
    
    //dynamic var id = ""

//    override static func primaryKey() -> String? {
//        return "id"
//    }
    
}
