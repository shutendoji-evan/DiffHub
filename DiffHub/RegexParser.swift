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
    func parseFileNames(fileStr: String) -> (String, String)?
    func parseStartLineNumber(title: String) -> (Int, Int)?
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
        
        let fileAPattern = "(?<=(--- a/)).*"
        let fileBParttern = "(?<=(\\+\\+\\+ b/)).*"
        
        guard let regexA = try? NSRegularExpression(pattern: fileAPattern, options: []) else {
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
        
        let startPatternRight = "\\+\\d+"
        guard let startRegexRight = try? NSRegularExpression(pattern: startPatternRight, options: []) else {
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
    
    func parseArrayToCodeLines(organizedArray: NSMutableArray) -> Array<DiffCodeLine>?  {
        //Get codelines DataSource
        var leftLineNum = 0
        var rightLineNum = 0
        
        var codeLines = Array<DiffCodeLine>()
        for item in organizedArray {
            if item is DiffCodeBlock {
                let blockObj = item as! DiffCodeBlock
                for i in 0..<blockObj.blockMinor!.count {
                    let codeLine = DiffCodeLine()
                    codeLine.type = .plusOrMinus
                    
                    if blockObj.blockMinor![i].characters.first == "$" {
                        codeLine.leftContent = ""
                        codeLine.isLeftNull = true
                    }
                    else {
                        codeLine.leftContent = blockObj.blockMinor![i]
                        codeLine.leftNum = leftLineNum
                        leftLineNum += 1
                    }
                    if blockObj.blockPlus![i].characters.first == "$" {
                        codeLine.rightContent = ""
                        codeLine.isRightNull = true
                    }
                    else {
                        codeLine.rightContent = blockObj.blockPlus![i]
                        codeLine.rightNum = rightLineNum
                        rightLineNum += 1
                    }
                    
                    codeLines.append(codeLine)
                }
                
            }
            else {
                let str = item as! String
                let codeLine = DiffCodeLine()
                
                let type : DiffCodeLine.CodeLineType = str.characters.first == "@" ? .title : .common
                codeLine.type = type
                
                if type == .title {
                    codeLine.sharedContent = str
                    guard let startNum = self.parseStartLineNumber(title: str) else {
                        return nil
                    }
                    codeLine.leftStartNum = startNum.0
                    leftLineNum = startNum.0
                    codeLine.rightStartNum = startNum.1
                    rightLineNum = startNum.1
                    
                }
                else if type == .common {
                    codeLine.leftContent = str
                    codeLine.rightContent = str
                    codeLine.leftNum = leftLineNum
                    codeLine.rightNum = rightLineNum
                    leftLineNum += 1
                    rightLineNum += 1
                }
                
                codeLines.append(codeLine)
            }
        }
        
        return codeLines
    }
    
}
