//
//  CarnetSoundCell.swift
//  mplango
//
//  Created by Thomas Petit on 09/11/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class CarnetSoundCell: UITableViewCell {
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()

    var item: Carnet? = nil

    
    @IBOutlet weak var backgroundRecord: UIView!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        
        backgroundRecord.layer.borderWidth = 1
        backgroundRecord.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        backgroundRecord.layer.cornerRadius = 15
        backgroundRecord.layer.masksToBounds = true
        
    }
    


    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
