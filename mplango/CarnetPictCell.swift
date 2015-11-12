//
//  CarnetPictCell.swift
//  mplango
//
//  Created by Thomas Petit on 09/11/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class CarnetPictCell: UITableViewCell {
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()

    var item: Carnet? = nil
    

    @IBOutlet weak var itemPhoto: UIView!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
       
        
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
