//
//  DiffCodeBlock.swift
//  DiffHub
//
//  Created by Evan Liang on 12/12/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import Foundation

class DiffCodeBlock {
    
    var minorNum = 0
    var plusNum = 0
    
    var blockArray = Array<String>()
    
    var blockMinor : Array<String>?
    var blockPlus : Array<String>?
    
    func append(line: String) {
        let firstChar = line.characters.first
        if firstChar == "+" {
            self.plusNum += 1
        }
        else if firstChar == "-" {
            self.minorNum += 1
        }
        self.blockArray.append(line)
    }
    
    func generateBlocks() {
        
        self.blockMinor = Array<String>()
        self.blockPlus = Array<String>()
        
        let diffNum = minorNum - plusNum
        
        for str in blockArray {
            if str.characters.first == "-" {
                self.blockMinor?.append(str)
            }
            else if str.characters.first == "+" {
                self.blockPlus?.append(str)
            }
        }

        if diffNum > 0 {
            //more minor
            for _ in 0..<diffNum {
                self.blockPlus?.append("$")
            }
            
        }
        else if diffNum < 0 {
            //more plus
            let diffNum = diffNum * -1
            for _ in 0..<diffNum {
                self.blockMinor?.append("$")
            }
            
        }
        else {
            //equal - arrays are ready
        }

    }
    
}
