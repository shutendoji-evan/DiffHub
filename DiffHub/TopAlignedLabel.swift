//
//  TopAlignedLabel.swift
//  DiffHub
//
//  Created by Hang Liang on 12/12/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import UIKit

@IBDesignable class TopAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        
        if let theText = text {
            
            let theTextNSAsNSString = theText as NSString
            //only NSString has this function
            
            let labelSize = theTextNSAsNSString.boundingRect(with:
                CGSize(width: self.frame.width,
                       height: .greatestFiniteMagnitude),
                       options: .usesLineFragmentOrigin,
                       attributes: [NSFontAttributeName: font],
                       context: nil).size
            
            super.drawText(in: CGRect(x:0,y: 0,width: self.frame.width, height:ceil(labelSize.height)))
    
        }
        else {
            //draw directly
            super.drawText(in: rect)
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
        
    }
    
}

