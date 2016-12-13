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
    
    func parseSections(fileStr: String) -> [NSTextCheckingResult]? {
        let filesPattern = "@@ -\\d*,\\d* \\+\\d*,\\d* @@.*\n"
        guard let regex = try? NSRegularExpression(pattern: filesPattern, options: []) else {
            print("regex sections failed")
            return nil
        }
        
        let sectionMatches = regex.matches(in: fileStr, options: [], range: NSRange(location: 0, length: fileStr.characters.count))
        
        return sectionMatches
    }
    
//    func parseMode(fileStr: String) -> String? {
//        let deletePattern = "diff --git a/.* b/.*\n"
//        let newPattern = "diff --git a/.* b/.*\n"
//        let indexPattern = "diff --git a/.* b/.*\n"
//        
//        guard let _ = try? NSRegularExpression(pattern: deletePattern, options: []) else {
//            print("regex mode failed")
//            return nil
//        }
//        
//        guard let _ = try? NSRegularExpression(pattern: newPattern, options: []) else {
//            print("regex mode failed")
//            return nil
//        }
//        
//        guard let _ = try? NSRegularExpression(pattern: indexPattern, options: []) else {
//            print("regex mode failed")
//            return nil
//        }
//        
//        return nil
//    }
    
    func parseFileNames(fileStr: String) -> (String, String)? {
        
        let fileAParttern = "(?<=(--- a/)).*"
        let fileBParttern = "(?<=(\\+\\+\\+ b/)).*"
        
        guard let regexA = try? NSRegularExpression(pattern: fileAParttern, options: []) else {
            print("regex parse filename A failed")
            return nil
        }
        guard let regexB = try? NSRegularExpression(pattern: fileBParttern, options: []) else {
            print("regex parse filename B failed")
            return nil
        }
        
        let fileStrNS = fileStr as NSString
        var strA = ""
        var strB = ""
        
        if let fileAMatches = regexA.matches(in: fileStr, options: [], range: NSRange(location: 0, length: fileStr.characters.count)).first  {
            strA = fileStrNS.substring(with: fileAMatches.range)
        }
        if let fileBMatches = regexB.matches(in: fileStr, options: [], range: NSRange(location: 0, length: fileStr.characters.count)).first {
            strB = fileStrNS.substring(with: fileBMatches.range)
        }
        
        
        return (strA, strB)
    }
    
}
