//
//  SearchRouteTableViewCell.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 24/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class SearchRouteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var routeTypeIcon: UIImageView!
    @IBOutlet weak var routeNameLabel: UILabel!
    @IBOutlet weak var routeInfoLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
