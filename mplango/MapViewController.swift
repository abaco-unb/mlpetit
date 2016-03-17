//
//  MapViewController.swift
//  mplango
//
//  Created by Bruno Ferreira on 12/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import CoreLocation


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var mkMapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    var locationManager = CLLocationManager()
    var posts = [Annotation]()
    
    var location:CLLocation!
    var street: String!
    var loggedUser: User!
    
    var restPath = "http://localhost:10088/maplango/public/post-rest" //"http://server.maplango.com.br/post-rest"
    var indicator:ActivityIndicator = ActivityIndicator()
    
    //Filtros: background e botões
    
    @IBOutlet weak var filtersView: UIView!
    @IBOutlet weak var recentsBtn: UIButton!
    @IBOutlet weak var defisBtn: UIButton!
    @IBOutlet weak var astucesBtn: UIButton!
    @IBOutlet weak var doutesBtn: UIButton!
    @IBOutlet weak var activiteBtn: UIButton!
    
    @IBOutlet weak var showFiltersBtn: UIButton!
    @IBOutlet weak var hideFiltersBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        filtersView.hidden = true
        
        //recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let user:Int = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", user)
        
        //recupera todos os posts e adiciona no mapa
        self.upServerPosts()
        
        //inicializa : get geo location data
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            NSLog("Serviço de localização indisponível")
        }
        
        
        self.mkMapView.showsUserLocation = true
        self.mkMapView.delegate = self
        self.mkMapView.mapType = MKMapType.Standard
        self.mkMapView.backgroundColor = UIColor.blueColor()
        
        //self.mkMapView.userTrackingMode = MKUserTrackingModeFollow;
        
        
        /**
         * GET STREET ADDRESS NAME
         */
                //MARK - add circle rounded user location
        ///addRadiusCircle(location)
        
        //let geocoder = CLGeocoder()
        //geocoder.reverseGeocodeLocation(location) {
            //(placemarks, error) -> Void in
            //if let placemarks = placemarks as? [CLPlacemark] where placemarks.count > 0 {
            //var placemark = placemarks[0]
            
            //if let validPlacemark = placemarks?[0]{
               // let placemark = validPlacemark as CLPlacemark;
                
                //println("placemark")
                //println(placemark)
                // Street addres
                //println("street")
                //println(placemark)
                //self.street = st
                //println("self.street")
                //println(self.street)
//            }
//        }
        //println("self.street")
        //println(self.street)
        //let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        //let userLocation = CLLocationCoordinate2D(latitude: -15.9041234,longitude: -48.079856)
        
        
        //let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        
        //longPressRecogniser.minimumPressDuration = 1.0
        //mkMapView.addGestureRecognizer(longPressRecogniser)


        
//        //MARK - retrieve all posts of Core Data
//        let request = NSFetchRequest(entityName: "Post")
//        if let posts = (try? moContext?.executeFetchRequest(request)) as? [Post] {
//            
//            if (posts.count > 0) {
//                for post in posts {
//                    //println(post)
//                    var latDelta:CLLocationDegrees = 0.01
//                    var longDelta:CLLocationDegrees = 0.01
//                    
//                    // show post on map
//                    let annotation = Annotation(title: post.text,
//                        locationName: post.locationName,
//                        category: post.category,
//                        coordinate: CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude),
//                        userImage: UIImage(data: (post.user as! User).image)!,
//                        entity: post
//                    )
//                    
//                    mkMapView.addAnnotation(annotation)
//                }
//            }
//        }
    }
    
    //MARK: Actions
    
    
    @IBAction func popover(sender: AnyObject) {
        
        self.performSegueWithIdentifier("showNotifications", sender: self)
        
    }
    
    @IBAction func showFilters(sender: AnyObject) {
        
        filtersView.hidden = false
        showFiltersBtn.hidden = true
        hideFiltersBtn.hidden = false
        hideFiltersBtn.enabled = true
        recentsBtn.enabled = true
        defisBtn.enabled = true
        astucesBtn.enabled = true
        doutesBtn.enabled = true
        activiteBtn.enabled = true
        
    }
    
    @IBAction func refreshLocation(sender: AnyObject) {
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mkMapView.setRegion(region, animated: true)
    }
    
    @IBAction func hideFilters(sender: AnyObject) {
        
        showFiltersBtn.hidden = false
        showFiltersBtn.enabled = true
        filtersView.hidden = true
        
    }
    
    @IBAction func showRecentPosts(sender: AnyObject) {
        
    }
    
    @IBAction func showDefisPosts(sender: AnyObject) {
        
    }
    
    @IBAction func showAstucesPosts(sender: AnyObject) {
        
    }
    
    @IBAction func showDoutesPosts(sender: AnyObject) {
        
    }
    
    @IBAction func showActivitesPosts(sender: AnyObject) {
        
    }
    
    func upServerPosts() {
        self.indicator.showActivityIndicator(self.view)
        //Checagem remota
        Alamofire.request(.GET, self.restPath)
            .responseSwiftyJSON({ (request, response, json, error) in
                self.indicator.hideActivityIndicator();
                   if let posts = json["data"].array {
                        for post in posts {
                            var latitude:Double  = 0
                            var longitude:Double = 0
                            var category:Int = 0;
                            
                            if let lat = post["latitude"].string {
                                latitude = Double(lat)!
                            }
                            
                            if let long = post["longitude"].string {
                                longitude = Double(long)!
                            }
                            
                            if let cat = post["category_id"].int {
                                category = cat
                            }
                            
                            print(latitude, longitude)
                             //show post on map
                             let annotation = Annotation(
                                title: post["text"].stringValue,
                                locationName: post["location"].stringValue,
                                audio: post["audio"].stringValue,
                                category: category,
                                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                userImage: post["photo"].stringValue
                             )
                             self.mkMapView.addAnnotation(annotation)
                        }
                   }
//                    //print(json["data"].array?.count)
//                   //print(json["data"].array?.count)
//                    
////                   if let posts = json["data"].array{
////                    for post in posts {
////                        print("post encontrado : ")
////                        print(post);
////                    
////                    }
//                    
////                        var latDelta:CLLocationDegrees = 0.01
////                        var longDelta:CLLocationDegrees = 0.01
////                        
////
//                    //}
//               }
            });
        
    }

    // MARK:- Retrieve Posts
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            print("auth in usevlocalization")
            mkMapView.showsUserLocation = true
        } else {
            print("auth in use non localication")
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
        
//        //MARK -
//        let post = Annotation(title: "Exemplo para o thomas",
//            locationName: "nome de teste agora",
//            audio: "",
//            category: 2,
//            coordinate: CLLocationCoordinate2D(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude),
//            userImage: " " //UIImage(data: loggedUser.image)!,
//        )
//        
//        mkMapView.addAnnotation(post)
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
            regionRadius * 2.0, regionRadius * 2.0)
        mkMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        self.location = manager.location!
        
        var userLocation = self.location.coordinate;
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(manager.location!) {
            (placemarks, error) -> Void in
            //if let placemarks = placemarks as? [CLPlacemark] where placemarks.count > 0 {
            //var placemark = placemarks[0]
            
            if let validPlacemark = placemarks?[0]{
                let placemark = validPlacemark as CLPlacemark;
                //self.location = String(placemark?.name)
                //print(location)
                print("placemark")
                print(String(placemark.name))
                // Street addres
                //print("street")
                //print(placemark)
                //self.street = st
                //print("self.street")
                //print(self.street)
            }
        }
        
        
//        let loadlocation = CLLocationCoordinate2D(
//            latitude: lat, longitude: long
//            
//        )
        
        let regionToZone = MKCoordinateRegionMake(manager.location!.coordinate, MKCoordinateSpanMake(1,10))
        
        mkMapView.setRegion(regionToZone, animated: true)
        locationManager.stopUpdatingLocation();
        
        centerMapOnLocation(userLocation)
        self.mkMapView.showAnnotations(self.mkMapView.annotations, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addRadiusCircle(location: CLLocation){
        let circle = MKCircle(centerCoordinate: location.coordinate, radius: 100 as CLLocationDistance)
        mkMapView.addOverlay(circle)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        print("map controller")
        print(segue.identifier)
        print("*************************************")
        
//        if segue.identifier == "post" {
//            
//            
//            print(street)
//            print(self.location.coordinate.latitude)
//            print(self.location.coordinate.longitude)
//            
//            let categoryController:CategoryViewController = segue.destinationViewController as! CategoryViewController
//            
//            let post = Annotation(title: "TESTE",
//                locationName: "Quadra 300 conjunto 14 cs 17",
//                audio: "",
//                category: 1,
//                coordinate: self.location.coordinate,
//                userImage: " "
//            )
//            print("prepareSegue MAp")
//            print(post)
//            
//        }
        
        // para a segue que mostra o popover de notificações
        if segue.identifier == "showNotifications" {
            
            let notifVC = segue.destinationViewController as UIViewController
            
            let controller = notifVC.popoverPresentationController
            
            if controller != nil {
                controller?.delegate = self
            }
            
        }
        
        
    }
    
    
    // para que o popover não esconda toda a tela
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    
    
    
    
}