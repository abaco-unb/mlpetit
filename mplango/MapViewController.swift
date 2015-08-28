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

    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var mkMapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    var locationManager = CLLocationManager()
    var posts = [Annotation]()
    var userLocation:CLLocationCoordinate2D!
    var street: String!
    var loggedUser: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        retrieveLoggedUser()
        
        
        //let barViewController = self.tabBarController?.viewControllers
        //println(barViewController)
        
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
        self.mkMapView.backgroundColor = UIColor.blueColor()
        
        //self.mkMapView.userTrackingMode = MKUserTrackingModeFollow;
        
        userLocation = CLLocationCoordinate2D(latitude: -15.9041234,longitude: -48.079856)
        
        /**
        * GET STREET ADDRESS NAME
        */
        var location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        //MARK - add circle rounded user location
        addRadiusCircle(location)
        
        var geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            if let placemarks = placemarks as? [CLPlacemark] where placemarks.count > 0 {
                var placemark = placemarks[0]
                //println("placemark")
                //println(placemark)
                // Street addres
                //println("street")
                //println(placemark)
                    //self.street = st
                    //println("self.street")
                    //println(self.street)
            }
        }
        //println("self.street")
        //println(self.street)
        centerMapOnLocation(userLocation)
        
        var longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        
        longPressRecogniser.minimumPressDuration = 1.0
        mkMapView.addGestureRecognizer(longPressRecogniser)
        
       
        //MARK - retrieve all posts of Core Data
        let request = NSFetchRequest(entityName: "Post")
        if let posts = moContext?.executeFetchRequest(request, error: nil) as? [Post] {
            
            if (posts.count > 0) {
                for post in posts {
                    //println(post)
                    var latDelta:CLLocationDegrees = 0.01
                    var longDelta:CLLocationDegrees = 0.01
                    
                    // show post on map
                    let annotation = Annotation(title: post.text,
                        locationName: post.locationName,
                        category: post.category,
                        coordinate: CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude),
                        userImage: UIImage(data: (post.user as! User).image)!,
                        entity: post
                        )
                    
                        mkMapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    func retrieveLoggedUser() {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let email: String = prefs.objectForKey("USEREMAIL") as! String
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        if let fetchResults = moContext?.executeFetchRequest(fetchRequest, error: nil) as? [User] {
            loggedUser = fetchResults[0];
            
        }
    
    }
    
    // MARK:- Retrieve Posts
    
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            println("auth in usevlocalization")
            mkMapView.showsUserLocation = true
        } else {
            println("auth in use non localication")
            let locationManager = CLLocationManager()
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            //mkMapView.showsUserLocation = true
            //locationManager.startUpdatingLocation()
        }
    }
    
    func handleLongPress(getstureRecognizer : UIGestureRecognizer){
        if getstureRecognizer.state != .Began { return }
        
        let touchPoint = getstureRecognizer.locationInView(self.mkMapView)
        let touchMapCoordinate = mkMapView.convertPoint(touchPoint, toCoordinateFromView: mkMapView )
        
        //MARK - 
        let post = Annotation(title: "Exemplo para o thomas",
            locationName: "nome de teste agora",
            category: 2,
            coordinate: CLLocationCoordinate2D(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude),
            userImage: UIImage(data: loggedUser.image)!,
            entity: nil
        )
        
        mkMapView.addAnnotation(post)
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
            regionRadius * 2.0, regionRadius * 2.0)
        mkMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        let regionToZone = MKCoordinateRegionMake(manager.location.coordinate, MKCoordinateSpanMake(1,10))
        mkMapView.setRegion(regionToZone, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addRadiusCircle(location: CLLocation){
        var circle = MKCircle(centerCoordinate: location.coordinate, radius: 100 as CLLocationDistance)
        mkMapView.addOverlay(circle)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        println("map controller")
        println(segue.identifier)
        println("*************************************")
        
        if segue.identifier == "post" {
            
            
            println(street)
            println(userLocation.latitude)
            println(userLocation.longitude)
            
            let categoryController:CategoryViewController = segue.destinationViewController as! CategoryViewController
            
            let post = Annotation(title: "TESTE",
                locationName: "Quadra 300 conjunto 14 cs 17",
                category: 1,
                coordinate: userLocation,
                userImage: UIImage(data: loggedUser.image)!,
                entity: nil
            )
            categoryController.post = post
            println("prepareSegue MAp")
            println(post)
            
        }
    }
}
