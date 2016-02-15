//
//  ActivityIndicator.swift
//  mplango
//
//  Created by Bruno on 13/02/16.
//  Copyright © 2016 unb.br. All rights reserved.
//

import Foundation
import UIKit

class ActivityIndicator {
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var loadingView: UIView!
    
    func showActivityIndicator(view: UIView) {
        dispatch_async(dispatch_get_main_queue()) {
            self.loadingView = UIView()
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
            self.loadingView.center = view.center
            self.loadingView.backgroundColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 0.7)
            self.loadingView.alpha = 0.7
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10
            
            self.spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            self.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
            self.spinner.center = CGPoint(x:self.loadingView.bounds.size.width / 2, y:self.loadingView.bounds.size.height / 2)
            
            self.loadingView.addSubview(self.spinner)
            view.addSubview(self.loadingView)
            self.spinner.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            self.spinner.stopAnimating()
            self.loadingView.removeFromSuperview()
        }
    }
    
}