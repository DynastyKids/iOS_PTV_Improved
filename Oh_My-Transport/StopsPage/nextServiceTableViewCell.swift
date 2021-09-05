//
//  nextServiceTableViewCell.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 18/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class nextServiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var routeSignLabel: UILabel!
    @IBOutlet weak var routeDestinationLabel: UILabel!
    @IBOutlet weak var routeDueTimeLabel: UILabel!
    @IBOutlet weak var routeStatusLabel: UILabel!
    @IBOutlet weak var routeDetailslabel: UILabel!
    @IBOutlet weak var routeToLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
