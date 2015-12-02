
//
//  TestsVC.swift
//  mplango
//
//  Created by Thomas Petit on 02/12/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData


class TestsVC: UIViewController {
    
    
    @IBOutlet weak var test1Btn: UIButton!
    @IBOutlet weak var test2Btn: UIButton!
    @IBOutlet weak var test3Btn: UIButton!
    @IBOutlet weak var test4Btn: UIButton!
    @IBOutlet weak var testMBtn: UIButton!
    
    @IBOutlet weak var test2OKBtn: UIButton!
    @IBOutlet weak var test3OKBtn: UIButton!
    @IBOutlet weak var test4OKBtn: UIButton!
    @IBOutlet weak var testMOKBtn: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        test2OKBtn.hidden = true
        test3OKBtn.hidden = true
        test4OKBtn.hidden = true
        testMOKBtn.hidden = true
        

        // Do any additional setup after loading the view.
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
