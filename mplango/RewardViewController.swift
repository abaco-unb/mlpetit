//
//  RewardViewController.swift
//  mplango
//
//  Created by Bruno on 29/08/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit

class RewardViewController: UIViewController, UINavigationControllerDelegate {
    
    var points: Int = 0
    
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
        
        print("points acumulados")
        print(self.points)
        
        self.pointsLabel.text = String(self.points)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
   
        if segue.identifier == "go_to_points" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            let pointsController:ProfileGameVC = navigationController.viewControllers[0] as! ProfileGameVC
            pointsController.navigationItem.hidesBackButton = true
            let closeBtn = UIBarButtonItem(title: "Fermer", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(goToMap))
            pointsController.navigationItem.leftBarButtonItem = closeBtn
            
        }
    }
    
    func goToMap(sender: AnyObject) {
        
    }
    
}
