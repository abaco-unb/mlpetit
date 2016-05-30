//
//  RewardViewController.swift
//  mplango
//
//  Created by Bruno on 29/08/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit

class RewardViewController: UIViewController, UINavigationControllerDelegate{
    
    var points = 0
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var goToMapBTN: UIButton!
    @IBOutlet weak var goToPointsBTN: UIButton!
    
    @IBOutlet weak var shareFbBTN: UIButton!
    
    @IBOutlet weak var shareTwBTN: UIButton!
    
    @IBOutlet weak var shareInstBTN: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goToMapBTN.layer.borderWidth = 2
        goToMapBTN.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        goToMapBTN.layer.cornerRadius = 10
        goToMapBTN.layer.masksToBounds = true
        
        
        goToPointsBTN.layer.borderWidth = 2
        goToPointsBTN.layer.borderColor = UIColor(hex: 0xFFCC66).CGColor
        goToPointsBTN.layer.cornerRadius = 10
        goToPointsBTN.layer.masksToBounds = true
        
        print("points")
        print(points)
        //pointsLabel.text = points.description
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
