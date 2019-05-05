//
//  disruptionTableViewCell.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 6/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class disruptionTableViewCell: UITableViewCell {
    @IBOutlet weak var disruptionTitleLabel: UILabel!
    @IBOutlet weak var disruptionPublishDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
