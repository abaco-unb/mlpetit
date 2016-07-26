//
//  ListActivitiesVC.swift
//  mplango
//
//  Created by Thomas Petit on 05/06/2016.
//  Copyright © 2016 unb.br. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

class ListActivitiesVC: UIViewController {
    
    //MARK: Properties
    
    var activity: Test!
    
    var userId:Int!
    
    var indicator:ActivityIndicator = ActivityIndicator()

    @IBOutlet weak var act1Btn: UIButton!
    @IBOutlet weak var stat1: UIImageView!
    @IBOutlet weak var act2Btn: UIButton!
    @IBOutlet weak var stat2: UIImageView!
    @IBOutlet weak var act3Btn: UIButton!
    @IBOutlet weak var stat3: UIImageView!
    @IBOutlet weak var act4Btn: UIButton!
    @IBOutlet weak var stat4: UIImageView!
    @IBOutlet weak var act5Btn: UIButton!
    @IBOutlet weak var stat5: UIImageView!
    @IBOutlet weak var act6Btn: UIButton!
    @IBOutlet weak var stat6: UIImageView!
    @IBOutlet weak var act7Btn: UIButton!
    @IBOutlet weak var stat7: UIImageView!
    @IBOutlet weak var act8Btn: UIButton!
    @IBOutlet weak var stat8: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)

        act1Btn.layer.borderWidth = 2
        act1Btn.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        act1Btn.layer.cornerRadius = 10
        act1Btn.layer.masksToBounds = true
        
        act2Btn.layer.borderWidth = 2
        act2Btn.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        act2Btn.layer.cornerRadius = 10
        act2Btn.layer.masksToBounds = true
        
        act3Btn.layer.borderWidth = 2
        act3Btn.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        act3Btn.layer.cornerRadius = 10
        act3Btn.layer.masksToBounds = true
        
        act4Btn.layer.borderWidth = 2
        act4Btn.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        act4Btn.layer.cornerRadius = 10
        act4Btn.layer.masksToBounds = true
        
        act5Btn.layer.borderWidth = 2
        act5Btn.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        act5Btn.layer.cornerRadius = 10
        act5Btn.layer.masksToBounds = true
        
        act6Btn.layer.borderWidth = 2
        act6Btn.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        act6Btn.layer.cornerRadius = 10
        act6Btn.layer.masksToBounds = true
        
        act7Btn.layer.borderWidth = 2
        act7Btn.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        act7Btn.layer.cornerRadius = 10
        act7Btn.layer.masksToBounds = true
        
        act8Btn.layer.borderWidth = 2
        act8Btn.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        act8Btn.layer.cornerRadius = 10
        act8Btn.layer.masksToBounds = true
        
//        self.upServerActivitiesStatus()
        
        
//        if activity.desc == "1" {
//            if activity.status == Test.SENT {
//                stat1.image = UIImage(named: "atividade_enviada")
//                act1Btn.enabled = false
//            }
//            else if activity.status == Test.SUCCESS {
//                stat1.image = UIImage(named: "atividade_aprovada")
//                act1Btn.enabled = false
//            }
//            else if activity.status == Test.FAILED {
//                stat1.image = UIImage(named: "atividade_refazer")
//            }
//        }
//            
//        if activity.desc == "2" {
//            if activity.status == Test.SENT {
//                stat2.image = UIImage(named: "atividade_enviada")
//                act2Btn.enabled = false
//            }
//            else if activity.status == Test.SUCCESS {
//                stat2.image = UIImage(named: "atividade_aprovada")
//                act2Btn.enabled = false
//            }
//            else if activity.status == Test.FAILED {
//                stat2.image = UIImage(named: "atividade_refazer")
//            }
//        }
//            
//        if activity.desc == "3" {
//            if activity.status == Test.SENT {
//                stat3.image = UIImage(named: "atividade_enviada")
//                act3Btn.enabled = false
//            }
//            else if activity.status == Test.SUCCESS {
//                stat3.image = UIImage(named: "atividade_aprovada")
//                act3Btn.enabled = false
//            }
//            else if activity.status == Test.FAILED {
//                stat3.image = UIImage(named: "atividade_refazer")
//            }
//        }
//        
//        if activity.desc == "4" {
//            if activity.status == Test.SENT {
//                stat4.image = UIImage(named: "atividade_enviada")
//                act4Btn.enabled = false
//            }
//            else if activity.status == Test.SUCCESS {
//                stat4.image = UIImage(named: "atividade_aprovada")
//                act4Btn.enabled = false
//            }
//            else if activity.status == Test.FAILED {
//                stat4.image = UIImage(named: "atividade_refazer")
//            }
//        }
//            
//        if activity.desc == "5" {
//            if activity.status == Test.SENT {
//                stat5.image = UIImage(named: "atividade_enviada")
//                act5Btn.enabled = false
//            }
//            else if activity.status == Test.SUCCESS {
//                stat5.image = UIImage(named: "atividade_aprovada")
//                act5Btn.enabled = false
//            }
//            else if activity.status == Test.FAILED {
//                stat5.image = UIImage(named: "atividade_refazer")
//            }
//        }
//    
//        if activity.desc == "6" {
//            if activity.status == Test.SENT {
//                stat6.image = UIImage(named: "atividade_enviada")
//                act6Btn.enabled = false
//            }
//            else if activity.status == Test.SUCCESS {
//                stat6.image = UIImage(named: "atividade_aprovada")
//                act6Btn.enabled = false
//            }
//            else if activity.status == Test.FAILED {
//                stat6.image = UIImage(named: "atividade_refazer")
//            }
//        }
//            
//        if activity.desc == "7" {
//            if activity.status == Test.SENT {
//                stat7.image = UIImage(named: "atividade_enviada")
//                act7Btn.enabled = false
//            }
//            else if activity.status == Test.SUCCESS {
//                stat7.image = UIImage(named: "atividade_aprovada")
//                act7Btn.enabled = false
//            }
//            else if activity.status == Test.FAILED {
//                stat7.image = UIImage(named: "atividade_refazer")
//            }
//        }
//        
//        if activity.desc == "8" {
//            if activity.status == Test.SENT {
//                stat8.image = UIImage(named: "atividade_enviada")
//                act8Btn.enabled = false
//            }
//            else if activity.status == Test.SUCCESS {
//                stat8.image = UIImage(named: "atividade_aprovada")
//                act8Btn.enabled = false
//            }
//            else if activity.status == Test.FAILED {
//                stat8.image = UIImage(named: "atividade_refazer")
//            }
//        }
        
    
    }
    
    func retrieveLoggedUser() {
        
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", userId)
        
    }
    
    func upServerActivitiesStatus() {
        
        self.indicator.showActivityIndicator(self.view)
        //        Checagem remota
        
        let params : [String: Int] = [
            "user": self.userId
        ]
        
        Alamofire.request(.GET, EndpointUtils.USER, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                let activity = json["data"]
                print(activity);
                
                    var id: Int = 0
                    var desc:String = ""
                    var level:Int = 0
                    var ownerName: String = ""
                    var ownerId: Int = 0
                    var status: String = "";
                
                    if let actId = activity["id"].int {
                        print("show id : ", actId)
                        id = actId
                    }
                        
                    if let actDesc = activity["desc"].string {
                        print("show desc : ", actDesc)
                        desc = actDesc
                    }
                        
                    if let actLevel = activity["level"]["id"].int {
                        print("show level : ",actLevel)
                        level = actLevel
                    }
                        
                    if let actOwnerName = activity["ownername"].string {
                        ownerName = actOwnerName
                    }
                        
                    if let actOwnerId = activity["ownerid"].int {
                        ownerId = actOwnerId
                    }
                        
                    if let actStatus = activity["nationality"].string {
                        status = actStatus
                    }
                
                let activities = Test(
                    id: id,
                    desc: desc,
                    level: level,
                    ownerName: ownerName,
                    ownerId: ownerId,
                    status: status
                )
                print(activities)
                self.indicator.hideActivityIndicator();
                
        });
    
    }

    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }




}
