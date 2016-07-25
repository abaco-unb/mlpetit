//
//  ProfileGameVC.swift
//  mplango
//
//  Created by Thomas Petit on 26/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class ProfileGameVC: UIViewController {
    
    var gameProfile: RUser!
    var userId:Int!
    
    var comPoints:CGFloat = 0.0
    var colPoints:CGFloat = 0.0
    
    var currentBadge:Int = 0
    
    var currentCom: Float = 0.0
    var currentCol: Float = 0.0
    
    @IBOutlet weak var bgProgressBarComp: UIImageView!
    
    @IBOutlet weak var bgProgressBarColab: UIImageView!
    
    @IBOutlet weak var badge1: UIImageView!
    @IBOutlet weak var badge2: UIImageView!
    @IBOutlet weak var badge3: UIImageView!
    @IBOutlet weak var badge4: UIImageView!
    @IBOutlet weak var badge5: UIImageView!
    
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        
        ActivityIndicator.instance.showActivityIndicator(self.view)
        let params : [String: Int] = [
            "id": self.userId,
            ]
        
        //Checagem remota
        Alamofire.request(.GET, EndpointUtils.USER, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                ActivityIndicator.instance.hideActivityIndicator();
                print("passou da primeira parte")
                let user = json["data"]
                
                if let comp = user["com_points"].int {
                    self.comPoints = CGFloat(100*comp)/self.bgProgressBarComp.frame.height
                    
                }
                
                if let colab = user["col_points"].int {
                   self.colPoints = CGFloat(100*colab)/self.bgProgressBarComp.frame.height
                }
                
                if let badge = user["badge"].int {
                    self.currentBadge = badge
                    self.displayBadge(badge)
                }
                print("----------------")
                print(self.comPoints)
                print(self.colPoints)
                print("----------------")
                print("passou da segunda parte")
                NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(ProfileGameVC.updateProgress), userInfo: nil, repeats: true)
                
            });
        
//        navigationItem.title = gameProfile.name
        
        self.navigationItem.leftBarButtonItem = nil
        
        
    }
    
    func displayBadge(number: Int) {
        
        print("display interno")
        
        for i in 0...number {
            switch i {
            case 1:
                self.badge1.image = UIImage( named: "badge_1_on")
            case 2:
                self.badge2.image = UIImage( named: "badge_2_on")
            case 3:
                self.badge3.image = UIImage( named: "badge_3_on")
            case 4:
                self.badge4.image = UIImage( named: "badge_4_on")
            case 5:
                self.badge5.image = UIImage( named: "badge_5_on")
            default:
                break
            }
        }
        print("display interno fim")
    }
    
    func updateProgress() {
        
        //self.comPoints/100
        
        self.currentCom += 0.5
        self.currentCol += 0.5
        
        if self.currentCom <= Float(self.comPoints) {
            print("preencher com : " + String(self.currentCom/100))
            fillComp(CGFloat(self.currentCom/100))
        }
        
        if self.currentCol <= Float(self.colPoints) {
            print("preencher colab : " + String(self.currentCol/100))
            fillColab(CGFloat(self.currentCol/100))
        }
    }
    
    func redraw (bg: UIImageView, imgName: String, percent : CGFloat )  {
        
        let tear:UIImage! = UIImage(named : imgName )!
        
        if tear ==  nil { return }
        let sz = tear.size
        let top = sz.height*( 1 - percent )
        UIGraphicsBeginImageContextWithOptions ( sz ,  false ,  0 )
        let con =  UIGraphicsGetCurrentContext ()
        UIColor.greenColor().setFill()
        CGContextFillRect ( con ,  CGRectMake ( 0 , top , sz . width , sz . height ))
        tear.drawAtPoint ( CGPointMake ( 0 , 0 ))
        bg.image =  UIGraphicsGetImageFromCurrentImageContext ()
        UIGraphicsEndImageContext()
    
    }
    
    
    func fillComp(value : CGFloat) {
        redraw(self.bgProgressBarComp, imgName: "barra_esquerda", percent: value)
    }
    
    func fillColab(value : CGFloat) {
        redraw(self.bgProgressBarColab, imgName: "barra_direita", percent: value)
    }
    
    
    func retrieveLoggedUser() {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
    }
    
}
