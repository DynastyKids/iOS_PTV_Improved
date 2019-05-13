//
//  upcomingServiceTableViewCell.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 13/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class upcomingServiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var serviceDestLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var dueTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
