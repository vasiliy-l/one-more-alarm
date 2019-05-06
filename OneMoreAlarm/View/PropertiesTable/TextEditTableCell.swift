//
//  TextEditTableCell.swift
//  OneMoreAlarm
//
//  Created by  William on 3/9/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import UIKit

class TextEditTableCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func prepareForReuse() {
        nameLabel.text = nil
        valueLabel.text = nil
    }
    
}
