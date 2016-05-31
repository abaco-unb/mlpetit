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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        
//        navigationItem.title = gameProfile.name
        
        self.navigationItem.leftBarButtonItem = nil

        
    }
    
    
    func retrieveLoggedUser() {
        
    }
    
}
