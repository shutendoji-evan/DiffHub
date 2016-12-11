//
//  RegexParser.swift
//  DiffHub
//
//  Created by Hang Liang on 12/11/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import Foundation
import RealmSwift

protocol RegexParser {
    func parseStringToFiles(diffStr: String) -> [NSTextCheckingResult]?
    func parseSections(fileStr : String) -> [NSTextCheckingResult]?
}

extension RegexParser {
    
    //parse whole diff file into each individual files
    func parseStringToFiles(diffStr: String) -> [NSTextCheckingResult]? {
        let filesPattern = "diff --git a/.*b/.*"
        guard let regex = try? NSRegularExpression(pattern: filesPattern, options: []) else {
            print("regex files failed")
            return nil
        }
    
        let fileMatches = regex.matches(in: diffStr, options: [], range: NSRange(location: 0, length: diffStr.characters.count))
        
        return fileMatches
    }
    
    func parseSections(fileStr : String) -> [NSTextCheckingResult]? {
        let filesPattern = "@@ -\\d*,\\d* \\+\\d*,\\d* @@"
        guard let regex = try? NSRegularExpression(pattern: filesPattern, options: []) else {
            print("regex files failed")
            return nil
        }
        
        let sectionMatches = regex.matches(in: fileStr, options: [], range: NSRange(location: 0, length: fileStr.characters.count))
        
        return sectionMatches
    }
    
}
