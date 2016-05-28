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
//        let borderAlpha : CGFloat = 0.7
//        let cornerRadius : CGFloat = 5.0
        
        btnConnection.backgroundColor = UIColor.clearColor()
        btnConnection.layer.borderWidth = 3.0
        btnConnection.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        
        
        btnInscription.backgroundColor = UIColor.clearColor()
        btnInscription.layer.borderWidth = 3.0
        btnInscription.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
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
