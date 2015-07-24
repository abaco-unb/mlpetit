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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var mkMapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var posts = [Post]()
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mkMapView.showsUserLocation = true
        } else {
            //locationManager.requestAlwaysAuthorization()
            //locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //locationManager.delegate = self
            //locationManager.startUpdatingLocation()
        }
    }
    
    func handleLongPress(getstureRecognizer : UIGestureRecognizer){
        if getstureRecognizer.state != .Began { return }
        
        let touchPoint = getstureRecognizer.locationInView(self.mkMapView)
        let touchMapCoordinate = mkMapView.convertPoint(touchPoint, toCoordinateFromView: mkMapView )
        
        
        let post = Post(title: "Exemplo para o thomas",
            locationName: "nome de teste agora",
            category: "Teste",
            coordinate: CLLocationCoordinate2D(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude))
        
        mkMapView.addAnnotation(post)
    }
    
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
        
        checkLocationAuthorizationStatus()
        self.mkMapView.showsUserLocation = true
        self.mkMapView.delegate = self
        self.mkMapView.mapType = MKMapType.Standard
        
        //self.mkMapView.userTrackingMode = MKUserTrackingModeFollow;
        
        let initialLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -15.909975,longitude: -48.076578)
        
        centerMapOnLocation(initialLocation)
        
        var longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        
        longPressRecogniser.minimumPressDuration = 1.0
        mkMapView.addGestureRecognizer(longPressRecogniser)
        
        
        // show artwork on map
        let post = Post(title: "Post exemplo 1",
            locationName: "nome de teste 1",
            category: "Challenge",
            coordinate: CLLocationCoordinate2D(latitude: -15.910756, longitude: -48.076539))
        
        // show artwork on map
        let post2 = Post(title: "Post exemplo 2",
            locationName: "nome de teste 2",
            category: "Default",
            coordinate: CLLocationCoordinate2D(latitude: -15.911519, longitude: -48.089617))
        
        mkMapView.addAnnotation(post)
        mkMapView.addAnnotation(post2)
    }
    
    let regionRadius: CLLocationDistance = 1000
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
            regionRadius * 2.0, regionRadius * 2.0)
        mkMapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func logoutTapped(sender: UIButton) {
        
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        let regionToZone = MKCoordinateRegionMake(manager.location.coordinate, MKCoordinateSpanMake(1,10))
        mkMapView.setRegion(regionToZone, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
