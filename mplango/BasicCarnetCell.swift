//
//  BasicCarnetCell.swift
//  mplango
//
//  Created by Thomas Petit on 11/11/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class BasicCarnetCell: UITableViewCell {
    
    
    
    // MARK: Properties

    
    @IBOutlet weak var itemWordLabel: UILabel!
    @IBOutlet weak var itemDescLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }



    
    
    
}
