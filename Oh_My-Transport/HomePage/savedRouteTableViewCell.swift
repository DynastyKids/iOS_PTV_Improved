
//
//  savedRouteTableViewCell.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 20/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class savedRouteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var routeTypeImage: UIImageView!
    @IBOutlet weak var routeNumberLabel: UILabel!
    @IBOutlet weak var routeNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
