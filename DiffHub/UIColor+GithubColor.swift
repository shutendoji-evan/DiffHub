//
//  UIColor+GithubColor.swift
//  DiffHub
//
//  Created by Hang Liang on 12/11/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    class func getOriFileRedColor() -> UIColor {
        return UIColor(red: 255/255, green: 236/255, blue: 236/255, alpha: 1.0)
    }
    
    class func getNewFileGreenColor() -> UIColor {
        return UIColor(red: 234/255, green: 255/255, blue: 234/255, alpha: 1.0)
    }
    
    class func getSectionTitleBlueColor() -> UIColor {
        return UIColor(red: 244/255, green: 247/255, blue: 251/255, alpha: 1.0)
    }
    
    class func getOriLineNumRedColor() -> UIColor {
        return UIColor(red: 255/255, green: 221/255, blue: 221/255, alpha: 1.0)
    }
    
    class func getNewLineNumGreenColor() -> UIColor {
        return UIColor(red: 219/255, green: 255/255, blue: 219/255, alpha: 1.0)
    }
    
    class func getNoContentGrayColor() -> UIColor {
        return UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
    }
}
