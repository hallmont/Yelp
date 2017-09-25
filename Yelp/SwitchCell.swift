//
//  SwitchCell.swift
//  Yelp
//
//  Created by John Nguyen on 9/21/17.
//  Copyright © 2017 John Nguyen. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    @objc optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    
    weak var delegate: SwitchCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        onSwitch.addTarget(self, action:#selector(SwitchCell.switchValueChanged), for: UIControlEvents.valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func switchValueChanged() {
        print( "Switch value Changed")
        
        delegate?.switchCell?( switchCell: self, didChangeValue: onSwitch.isOn)
    }
}
