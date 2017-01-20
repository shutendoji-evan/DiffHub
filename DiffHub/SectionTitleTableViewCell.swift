//
//  SectionTitleTableViewCell.swift
//  DiffHub
//
//  Created by Hang Liang on 12/12/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import UIKit

class SectionTitleTableViewCell: UITableViewCell {

    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var leftPaddingView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
