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
    
    var stopComIncrement:Bool = false
    var stopColIncrement:Bool = false
    
    @IBOutlet weak var bgProgressBarComp: UIImageView!
    
    @IBOutlet weak var bgProgressBarColab: UIImageView!
    
    @IBOutlet weak var msgBadge: UILabel!
    @IBOutlet weak var msgFunction: UILabel!
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
        
        self.msgBadge.hidden = true
        self.msgFunction.hidden = true
        
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
                    
                }
                print("----------------")
                print(self.comPoints)
                print(self.colPoints)
                print("----------------")
                print("passou da segunda parte")
                NSTimer.scheduledTimerWithTimeInterval(0.000001, target: self, selector: #selector(ProfileGameVC.updateProgress), userInfo: nil, repeats: true)
                
            });
        
//        navigationItem.title = gameProfile.name
        
        self.navigationItem.leftBarButtonItem = nil
        
        
    }
    
    func displayBadge(number: Int) {
        
        print("display interno")
        var view : UIImageView = self.badge1
        switch number {
            case 1:
                view = self.badge1
            case 2:
                view = self.badge2
            case 3:
                view = self.badge3
            case 4:
                view = self.badge4
            case 5:
                view = self.badge5
            default:
                break
        }
        self.animationScaleEffect(view, animationTime: 0.7)
        view.image = UIImage( named: GamificationRules.IMG_BADGE[number])
        
        let firstBadge : String = number < 5 ? GamificationRules.NAME_BADGE[number+1] : ""
        let msg = "Le badge " + GamificationRules.NAME_BADGE[number] + " a été obtenu ! Prochaine étape: " + firstBadge
        
        self.msgBadge.text = msg
        self.msgBadge.hidden = false
        
        let msg2 : String = "Fonction " + GamificationRules.FUCTION_BADGE[number] + " débloquée"
        
        self.msgFunction.text = msg2
        self.msgFunction.hidden = false
        
        print("display interno fim")
    }
    
    func animationScaleEffect(view:UIImageView,animationTime:Float)
    {
        UIView.animateWithDuration(NSTimeInterval(animationTime), animations: {
            
            view.transform = CGAffineTransformMakeScale(0.6, 0.6)
            
            },completion:{completion in
                UIView.animateWithDuration(NSTimeInterval(animationTime), animations: { () -> Void in
                    
                    view.transform = CGAffineTransformMakeScale(1, 1)
                })
        })
        
    }
    
    func updateProgress() {
        
        if self.currentCom <= Float(self.comPoints) {
            if((stopComIncrement) != true) {
                self.currentCom += 0.5
                
            }
            //print("preencher com : " + String(self.currentCom/100))
            fillComp(CGFloat(self.currentCom/100))
            print("igual")
            print(self.currentCom == 32.0)
            
        } else {
            stopComIncrement = true
        }
        
        if self.currentCol <= Float(self.colPoints) {
            if((stopColIncrement) != true) {
                self.currentCol += 0.5
                
            }
            //print("preencher colab : " + String(self.currentCol/100))
            fillColab(CGFloat(self.currentCol/100))
        } else {
            stopColIncrement = true
        }
        
        if self.currentCom == 13.5 && self.currentCol == 13.5{
            print("(1)")
            self.displayBadge(1)
        }
        
        if self.currentCom == 32.0 && self.currentCol == 32.0{
            print("(2)")
            self.displayBadge(2)
        }
        
        if self.currentCom == 52.0 && self.currentCol == 52.0{
            print("(3)")
            self.displayBadge(3)
        }
        
        if self.currentCom == 71.0 && self.currentCol == 71.0{
            print("(4)")
            self.displayBadge(4)
        }
        
        if self.currentCom == 90.0 && self.currentCol == 90.0{
            print("(5)")
            self.displayBadge(5)
        }
        
        
        if(self.currentCom == 100.0) {
            stopComIncrement = true
            stopColIncrement = true
        }
        
    }
    
    func redraw (bg: UIImageView, imgName: String, percent : CGFloat, color: String)  {
        
        let tear:UIImage! = UIImage(named : imgName )!
        
        if tear ==  nil { return }
        let sz = tear.size
        let top = sz.height*( 1 - percent )
        UIGraphicsBeginImageContextWithOptions ( sz ,  false ,  0 )
        let con =  UIGraphicsGetCurrentContext ()
        if color == "y" {
            UIColor(hex: 0xFFC400).setFill()
        } else if color == "r" {
            UIColor(hex: 0xFF5252).setFill()
        }
        CGContextFillRect ( con ,  CGRectMake ( 0 , top , sz . width , sz . height ))
        tear.drawAtPoint ( CGPointMake ( 0 , 0 ))
        bg.image =  UIGraphicsGetImageFromCurrentImageContext ()
        UIGraphicsEndImageContext()
    
    }
    
    
    func fillComp(value : CGFloat) {
        redraw(self.bgProgressBarComp, imgName: "barra_esquerda", percent: value, color: "y")
    }
    
    func fillColab(value : CGFloat) {
        redraw(self.bgProgressBarColab, imgName: "barra_direita", percent: value, color : "r")
    }
    
    
    func retrieveLoggedUser() {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        
    }
    
}
