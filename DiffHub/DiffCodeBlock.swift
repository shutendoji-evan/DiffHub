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
    
    func generateMinorBlock() -> Array<String> {
        
        let diffNum = minorNum - plusNum
        
        if diffNum > 0 {
            //more minor
        }
        else if diffNum < 0 {
            //more plus
        }
        else {
            //equal
            
        }
        
        return [String]()
    }
    
    func generatePlusBlock() {
        
    }
}
