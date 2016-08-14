//
//  LikeViewController.swift
//  mplango
//
//  Created by Thomas Petit on 14/08/2016.
//  Copyright © 2016 unb.br. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

class LikeViewController: UIViewController {

    static let instance = LikeViewController()
    
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var likedUser: UIImageView!
    @IBOutlet weak var likingUser: UIImageView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.likeView.clipsToBounds = true
        self.likeView.layer.cornerRadius = 10
        
        likedUser.layer.cornerRadius = 25
        likedUser.layer.masksToBounds = true

        likingUser.layer.cornerRadius = 25
        likingUser.layer.masksToBounds = true
        
        label1.layer.cornerRadius = 15
        label1.layer.masksToBounds = true

        label2.layer.cornerRadius = 15
        label2.layer.masksToBounds = true
        
        label3.layer.cornerRadius = 15
        label3.layer.masksToBounds = true
        
        dismissLikeIndicator()

    }
    
    
    func dismissLikeIndicator() {
        
        UIView.animateWithDuration(5, animations: {
            self.view.alpha = 0
            })
        { _ in
                self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    
}
