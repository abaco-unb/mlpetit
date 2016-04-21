//
//  CarnetTableViewCell.swift
//  mplango
//
//  Created by Thomas Petit on 19/04/2016.
//  Copyright © 2016 unb.br. All rights reserved.
//

import UIKit


class CarnetTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var wordLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
