//
//  InitialViewController.swift
//  mplango
//
//  Created by Carlos Wagner Pereira de Morais on 24/07/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var btnConnection: UIButton!
    @IBOutlet weak var btnInscription: UIButton!
    @IBOutlet weak var btnFace: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let borderAlpha : CGFloat = 0.7
        let cornerRadius : CGFloat = 5.0
        
        btnConnection.frame = CGRectMake(100, 100, 200, 40)
        btnConnection.setTitle("CONNECTION", forState: UIControlState.Normal)
        btnConnection.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnConnection.backgroundColor = UIColor.clearColor()
        btnConnection.layer.borderWidth = 1.0
        btnConnection.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).CGColor
        btnConnection.layer.cornerRadius = cornerRadius
        
        btnInscription.frame = CGRectMake(100, 100, 200, 40)
        btnInscription.setTitle("INSCRIPTION", forState: UIControlState.Normal)
        btnInscription.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnInscription.backgroundColor = UIColor.clearColor()
        btnInscription.layer.borderWidth = 1.0
        btnInscription.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).CGColor
        btnInscription.layer.cornerRadius = cornerRadius
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
