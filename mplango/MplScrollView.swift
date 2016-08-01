//
//  MplScrollView.swift
//  mplango
//
//  Created by Bruno on 17/07/16.
//  Copyright © 2016 unb.br. All rights reserved.
//

import UIKit
import Foundation

class MplScrollView: UIScrollView {
    
//    init(frame: CGRect) {
//        super.init(frame: frame)
//        tableView = UITableView(frame: frame)
//    }
    
    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        print(view.tag)
        print(view.frame)
        if view.isKindOfClass(UIButton) {
            print("UIButton clicked")
            return  true
        }
        print(super.touchesShouldCancelInContentView(view))
        //return false
        return  super.touchesShouldCancelInContentView(view)
    }
}