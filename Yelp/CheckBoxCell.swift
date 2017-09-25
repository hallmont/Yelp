//
//  CheckBox.swift
//  Yelp
//
//  Created by John Nguyen on 9/22/17.
//  Copyright © 2017 John Nguyen. All rights reserved.
//

import UIKit

enum CheckBoxStatusType {
    case checked
    case unchecked
    case collapsed
}

class CheckBoxCell: UITableViewCell {

    @IBOutlet weak var checkBoxLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    let checkedImage = UIImage( named: "checkbox")
    let unCheckedImage = UIImage( named: "checkbox_unselect")
    let collapsedImage = UIImage( named: "collapsed")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateToChecked() {
        statusImageView.image = checkedImage
    }
    
    func updateStatus( status: CheckBoxStatusType ) {
        switch status {
        case .checked :
            statusImageView.image = checkedImage
        case .unchecked :
            statusImageView.image = unCheckedImage
        case .collapsed :
            statusImageView.image = collapsedImage
        }
    }
    

}
