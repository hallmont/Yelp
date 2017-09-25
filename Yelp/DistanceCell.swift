//
//  DistanceCell.swift
//  Yelp
//
//  Created by John Nguyen on 9/22/17.
//  Copyright © 2017 John Nguyen. All rights reserved.
//

import UIKit

class DistanceCell: UITableViewCell {

    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print( "** DistanceCell: awakeFromNib()")
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
