
//
//  TestsVC.swift
//  mplango
//
//  Created by Thomas Petit on 02/12/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

class TestsVC: UIViewController {
    
    //MARK: Properties
    
    var user: RUser!
    var userId:Int!
    
    var indicator:ActivityIndicator = ActivityIndicator()
    
    @IBOutlet weak var test1Btn: UIButton!
    @IBOutlet weak var test2Btn: UIButton!
    @IBOutlet weak var test3Btn: UIButton!
    @IBOutlet weak var test4Btn: UIButton!
    @IBOutlet weak var testMBtn: UIButton!
    
    @IBOutlet weak var test2OKBtn: UIButton!
    @IBOutlet weak var test3OKBtn: UIButton!
    @IBOutlet weak var test4OKBtn: UIButton!
    
    @IBOutlet weak var evalBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        upServerUser()
        
        self.test2OKBtn.hidden = true
        self.test3OKBtn.hidden = true
        self.test4OKBtn.hidden = true
        self.evalBtn.hidden = true

    }
    
    func retrieveLoggedUser() {
        
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", userId)
        
    }
    
    func upServerUser() {
        self.indicator.showActivityIndicator(self.view)
        
        let params : [String: Int] = [
            "id": self.userId
            
        ]
        
        //Checagem remota
        Alamofire.request(.GET, EndpointUtils.USER, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                self.indicator.hideActivityIndicator();
                let user = json["data"]
                print(user);
                
                if let lev = user["level"]["id"].int {
                    print("show level : ", lev)
                    if lev == User.BEGINNER {
                        self.test2OKBtn.hidden = true
                        self.test3OKBtn.hidden = true
                        self.test4OKBtn.hidden = true
                        self.evalBtn.hidden = true
                    }
                    else if lev == User.HIGH_BEGINNER {
                        self.test2Btn.hidden = true
                        
                        self.test2OKBtn.hidden = false
                        
                        self.test3OKBtn.hidden = true
                        self.test4OKBtn.hidden = true
                        self.evalBtn.hidden = true
                    }
                    else if lev == User.INTERMEDIATE {
                        self.test2Btn.hidden = true
                        self.test3Btn.hidden = true
                        
                        self.test2OKBtn.hidden = false
                        self.test3OKBtn.hidden = false
                        
                        self.test4OKBtn.hidden = true
                        self.evalBtn.hidden = true
                    }
                    else if lev == User.ADVANCED {
                        self.test2Btn.hidden = true
                        self.test3Btn.hidden = true
                        self.test4Btn.hidden = true
                        
                        self.test2OKBtn.hidden = false
                        self.test3OKBtn.hidden = false
                        self.test4OKBtn.hidden = false
                        
                        self.evalBtn.hidden = true
                    }
                    else if lev == User.MEDIATOR {
                        self.test1Btn.hidden = true
                        self.test2Btn.hidden = true
                        self.test3Btn.hidden = true
                        self.test4Btn.hidden = true
                        self.testMBtn.hidden = true
                        
                        self.test2OKBtn.hidden = true
                        self.test3OKBtn.hidden = true
                        self.test4OKBtn.hidden = true
                        
                        self.evalBtn.hidden = false
                        self.evalBtn.enabled = true
                        
                        self.navigationItem.title = "Tests"
                    }
                }
                
            });
        
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
