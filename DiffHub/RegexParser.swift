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
    
    func parseStartLineNumber(title: String) -> (Int, Int)? {
        
        let startPatternLeft = "(?<=@@ -)\\d+"
        
        guard let startRegex = try? NSRegularExpression(pattern: startPatternLeft, options: []) else {
            print("regex parse left lineNum generate failed")
            return nil
        }

        guard let startLeft = startRegex.matches(in: title, options: [], range: NSRange(location: 0, length: title.characters.count)).first else {
            print("regex parse left line number start failed")
            return nil
        }
        
        guard let numStartLeft = Int((title as NSString).substring(with: startLeft.range)) else {
            print("parse numStartLeft failed")
            return nil
        }
        
        let startPateernRight = "\\+\\d+"
        guard let startRegexRight = try? NSRegularExpression(pattern: startPateernRight, options: []) else {
            print("regex parse right lineNum generate failed")
            return nil
        }
        
        guard let startRight = startRegexRight.matches(in: title, options: [], range: NSRange(location: 0, length: title.characters.count)).first else {
            print("regex parse right line number start failed")
            return nil
        }
        
        guard let numStartRight = Int((title as NSString).substring(with: startRight.range)) else {
            print("parse numStartRight failed")
            return nil
        }
        
        return (numStartLeft, numStartRight)
    }
    
}
