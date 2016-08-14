////
////  LikeIndicator.swift
////  mplango
////
////  Created by Thomas Petit on 13/08/2016.
////  Copyright © 2016 unb.br. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class LikeIndicator {
//    
//    static let instance = LikeIndicator()
//    var likeView: UIView!
//    var userPicture: UIImage!
//    var likedUserPicture: UIImage!
//    var label1: UILabel!
//    var label2: UILabel!
//
//    func showLikeIndicator(view: UIView) {
//        dispatch_async(dispatch_get_main_queue()) {
//            self.likeView = UIView()
//            self.likeView.frame = CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0)
//            self.likeView.center = view.center
//            self.likeView.backgroundColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 0.7)
//            self.likeView.alpha = 0.7
//            self.likeView.clipsToBounds = true
//            self.likeView.layer.cornerRadius = 10
//
////            print("mostrando foto de quem recebeu o like")
////            self.likedUserPicture = self.createLikedUserPicture("listen_btn.png", frame: CGRectMake(15, 10, 20, 20))
////            
////            print("mostrando foto de quem fez o like")
////            self.userPicture = self.createUserPicture("stop_btn.png", frame: CGRectMake(15, 10, 20, 20))
////            self.likedUserPicture = self.createLikedUserPicture("listen_btn.png", frame: CGRectMake(15, 10, 20, 20))
//            
//            
//            self.label1 = self.createLabel1(CGRectMake(self.likeView.frame.width - 50, 10, 50, 21))
//            self.likeView.addSubview(self.label1)
//          
//            view.addSubview(self.likeView)
//            
//            UIView.animateWithDuration(3, animations: {
//                self.likeView.alpha = 0
//            }) { _ in
//                self.likeView.removeFromSuperview()
//            }
//
//        }
//    }
//    
//
//    func createLabel1(frame : CGRect) -> UILabel {
//        let label1 = UILabel(frame: frame)
//        //label.center = CGPointMake(160, 284)
//        label1.textAlignment = NSTextAlignment.Center
//        label1.text = "5 points collaboratifs"
//        label1.font = UIFont.systemFontOfSize(20)
//        label1.textColor = UIColor(hex: 0xFF5252)
//        return label1
//    }
//    
//    func createLabel2(frame : CGRect) -> UILabel {
//        let label2 = UILabel(frame: frame)
//        //label.center = CGPointMake(160, 284)
//        label2.textAlignment = NSTextAlignment.Center
//        label2.text = "1 de tes points participatifs est devenu collaboratif"
//        label2.font = UIFont.systemFontOfSize(20)
//        label2.textColor = UIColor(hex: 0xFFC400)
//        return label2
//    }
//    
//    func createUserPicture (imagee : String, frame : CGRect ) -> UIImage {
//        let imageView = UIImage(named: imagee) as UIImage?
//        return imageView!
//    }
//    
//    func createLikedUserPicture (imagee : String, frame : CGRect ) -> UIImage {
//        let imageView = UIImage(named: imagee) as UIImage?
//        return imageView!
//    }
//    
//    
//    func addConstraint(view : UIView, ui : AnyObject, xattr: NSLayoutAttribute, xcons: CGFloat, wcons: CGFloat, hcons:CGFloat) {
//        
//        let horizontalConstraint = NSLayoutConstraint(item: ui, attribute: xattr, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: xattr, multiplier: 1, constant: xcons)
//        view.addConstraint(horizontalConstraint)
//        
//        let verticalConstraint = NSLayoutConstraint(item: ui, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
//        view.addConstraint(verticalConstraint)
//        
//        let widthConstraint = NSLayoutConstraint(item: ui, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: wcons)
//        view.addConstraint(widthConstraint)
//        
//        let heightConstraint = NSLayoutConstraint(item: ui, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: hcons)
//        view.addConstraint(heightConstraint)
//    }
//    
//}