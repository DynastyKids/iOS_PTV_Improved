//
//  RoutesStopTableViewCell.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 19/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class RoutesStopTableViewCell: UITableViewCell {
    
    @IBOutlet weak var routeStopNameLabel: UILabel!
    @IBOutlet weak var routeAdditionInfoLabel: UILabel!
    @IBOutlet weak var routeStopTimeLabel: UILabel!
    @IBOutlet weak var routeStatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
