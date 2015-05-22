//
//  MapViewController.swift
//  mplango
//
//  Created by Bruno Ferreira on 12/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var labelUsername: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func zoomIn(sender: AnyObject) {
    }
    @IBAction func changeMapType(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        var isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        
        NSLog("status autenticação: %ld", isLoggedIn)
        
        if (isLoggedIn < 1) {
            NSLog("status autenticação é nullo - não autorizado!")
            self.performSegueWithIdentifier("gobk_login", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    }
    
    @IBAction func logoutTapped(sender: UIButton) {
        
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
