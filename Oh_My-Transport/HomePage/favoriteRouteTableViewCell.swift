//
//  favoriteRouteTableViewCell.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 5/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class favoriteRouteTableViewCell: UITableViewCell {

    @IBOutlet weak var routeSign: UIButton!
    @IBOutlet weak var routeNumber: UILabel!
    @IBOutlet weak var routeInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
