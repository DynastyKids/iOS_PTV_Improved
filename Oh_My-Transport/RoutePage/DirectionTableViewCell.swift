//
//  DirectionTableViewCell.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 19/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class DirectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var directionNameLabel: UILabel!
    @IBOutlet weak var nearStopLabel: UILabel!
    
    @IBOutlet weak var departure0Time: UILabel!
    @IBOutlet weak var departure0Countdown: UILabel!
    @IBOutlet weak var departure1Time: UILabel!
    @IBOutlet weak var departure1Countdown: UILabel!
    @IBOutlet weak var departure2Time: UILabel!
    @IBOutlet weak var departure2Countdown: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
