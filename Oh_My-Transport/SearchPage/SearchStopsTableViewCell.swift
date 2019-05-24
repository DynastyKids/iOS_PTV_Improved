//
//  SearchStopsTableViewCell.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 24/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class SearchStopsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stopIcon: UIImageView!
    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var stopSuburbLabel: UILabel!
    @IBOutlet weak var stopDistanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
