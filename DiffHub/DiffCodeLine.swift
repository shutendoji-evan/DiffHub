//
//  DiffCodeLine.swift
//  DiffHub
//
//  Created by Evan Liang on 12/12/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import Foundation



class DiffCodeLine {
    
    enum CodeLineType {
        case plusOrMinus
        case common
        case title
    }
    
    var type = CodeLineType.common
    
    var leftContent = ""
    var leftNum = 0
    var leftStartNum = 0
    
    var rightContent = ""
    var rightNum = 0
    var rightStartNum = 0
    
    var sharedContent = ""
    
    var isLeftNull = false
    var isRightNull = false
    
}
