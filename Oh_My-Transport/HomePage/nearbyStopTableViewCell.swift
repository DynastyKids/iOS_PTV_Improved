//
//  nearbyStopTableViewCell.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 5/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class nearbyStopTableViewCell: UITableViewCell {
    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var stopSuburbLabel: UILabel!
    @IBOutlet weak var depature1Label: UILabel!
    @IBOutlet weak var dep1timeLabel: UILabel!
    @IBOutlet weak var departure2Label: UILabel!
    @IBOutlet weak var dep2timeLabel: UILabel!
    @IBOutlet weak var departure3Label: UILabel!
    @IBOutlet weak var dep3timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
