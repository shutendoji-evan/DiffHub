//
//  PullRequestInfoTableViewCell.swift
//  DiffHub
//
//  Created by Hang Liang on 12/10/16.
//  Copyright © 2016 Evan Liang. All rights reserved.
//

import UIKit
import Alamofire

class PullRequestInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarIV: UIImageView!
    @IBOutlet weak var pullTitleLabel: UILabel!
    @IBOutlet weak var pullDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
