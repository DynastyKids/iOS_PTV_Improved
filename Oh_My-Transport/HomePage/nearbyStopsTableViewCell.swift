//
//  nearbyStopsTableViewCell.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 20/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class nearbyStopsTableViewCell: UITableViewCell {
    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var stopSuburbLabel: UILabel!
    
    @IBOutlet weak var departure0Route: UILabel!
    @IBOutlet weak var departure0Time: UILabel!
    @IBOutlet weak var departure1Route: UILabel!
    @IBOutlet weak var departure1Time: UILabel!
    @IBOutlet weak var departure2Route: UILabel!
    @IBOutlet weak var departure2Time: UILabel!
    
    @IBOutlet weak var nearbyTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
