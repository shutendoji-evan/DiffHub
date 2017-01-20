//
//  CodeLineTableViewCell.swift
//  DiffHub
//
//  Created by Hang Liang on 12/11/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import UIKit

class CodeLineTableViewCell: UITableViewCell {

    @IBOutlet weak var leftLineNumLabel: UILabel!
    @IBOutlet weak var leftCodeLabel: UILabel!
    
    @IBOutlet weak var rightLineNumLabel: UILabel!
    @IBOutlet weak var rightCodeLabel: UILabel!
    
    
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
