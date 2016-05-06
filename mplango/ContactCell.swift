//
//  ContactCell.swift
//  mplango
//
//  Created by Thomas Petit on 28/04/2016.
//  Copyright © 2016 unb.br. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    
    
    @IBOutlet weak var contactPicture: UIImageView!
    
    @IBOutlet weak var contactName: UILabel!
    
    var contact: RUser!
    var restPath = "http://server.maplango.com.br/user-rest"
    var userId:Int!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
