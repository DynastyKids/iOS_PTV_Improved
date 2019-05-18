//
//  stopInfoTableViewCell.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 18/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class stopInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var disruptionButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
