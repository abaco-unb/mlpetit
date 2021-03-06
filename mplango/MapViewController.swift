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
import AlamofireSwiftyJSON
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var mkMapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    var locationManager = CLLocationManager()
    
    var posts = [PostAnnotation]()
    var filteredPosts = [PostAnnotation]()
    
    var showCategory:Int = 0
    
    var location:CLLocation!
    var street: String!
    var loggedUser: User!
    
    var indicator:ActivityIndicator = ActivityIndicator()
    
    var zoomLevel = Double()
    var iphoneScaleFactorLatitude = Double()
    var iphoneScaleFactorLongitude = Double()
    var CanUpdateMap: Bool = false
    var arrDicPostsWithLatitudeLongitude = [Dictionary<String, Double>]()
    
    let clusteringManager = FBClusteringManager()
    
//    let searchController = UISearchController(searchResultsController: nil)

    var resultSearchController = UISearchController(searchResultsController: nil)
    
    //Filtros: background e botões
    
    @IBOutlet weak var filtersView: UIView!
    @IBOutlet weak var showAllBtn: UIButton!
    @IBOutlet weak var defisBtn: UIButton!
    @IBOutlet weak var astucesBtn: UIButton!
    @IBOutlet weak var evenementsBtn: UIButton!
    @IBOutlet weak var curiositesBtn: UIButton!
    
    @IBOutlet weak var showFiltersBtn: UIButton!
    @IBOutlet weak var hideFiltersBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        filtersView.hidden = true
        
        //recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let user:Int = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", user)
        
        self.clusteringManager.delegate = self
        
        self.mkMapView.showsUserLocation = true
        self.mkMapView.delegate = self
        self.mkMapView.mapType = MKMapType.Standard
        
        //inicializa : get geo location data
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            print("passou aqui e habilitou o serviço de localização")
            //print(locationManager.location!)
            
        } else {
            NSLog("Serviço de localização indisponível")
        }
        
        //recupera todos os posts e adiciona no mapa
        self.upServerPosts()
    }
    
    func upServerPosts() {
        ActivityIndicator.instance.showActivityIndicator(self.view)
        //Checagem remota
        Alamofire.request(.GET, EndpointUtils.POST)
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                ActivityIndicator.instance.hideActivityIndicator()
                if let posts = json["data"].array {
                    print(1)
                    for post in posts {
                        print(post)
                        var postId:Int = 0
                        var latitude:Double  = 0
                        var longitude:Double = 0
                        var category:Int = 0
                        //var likes:Int = 0
                        //var imageUrl:String = ""
                        var ownerId: Int = 0
                        //var audioUrl: String = ""
                        
                        //var comments: Array<Comment> = [Comment]();
                        
                        if let id = post["id"].int {
                            postId = id
                            
                        }
                        
                        if let lat = post["latitude"].string {
                            latitude = Double(lat)!
                            
                        }
                        
                        if let long = post["longitude"].string {
                            longitude = Double(long)!
                        }
                        
                        if let cat = post["category_id"].int {
                            category = cat
                        }
                        
                        //
                        
                        if let owner = post["user"]["id"].int {
                            print("+++++++++++++++++++")
                            print(owner)
                            print("+++++++++++++++++++")
                            ownerId = owner
                        }
                        
                        //print("Comentários do Post", comments)
                        //show post on map
                        let postAnnotation = PostAnnotation(
                            id: postId,
                            title: post["user"]["name"].stringValue,
                            text: post["text"].stringValue,
                            locationName: post["location"].stringValue,
                            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                            category: category,
                            owner: ownerId,
                            time: post["created"].stringValue
                        )
                        //self.arrDicPostsWithLatitudeLongitude.append(["latitude" : latitude, "longitude" : longitude])
                        self.posts.append(postAnnotation);
                        //self.mkMapView.addAnnotation(annotation)
                    }
                }
                print(2)
                print( "total de posts : ",self.posts.count)
                self.clusteringManager.addAnnotations(self.posts)
                self.displayPostsInMap()
                
                print(self.posts.first!.coordinate)
                if self.posts.count >= 1 {
                    self.centerMapOnLocation(self.posts.last!.coordinate)
                } else {
                    self.centerMapOnLocation(self.location.coordinate)
                }
            });
        
    }

    
    // MARK: Search bar
    
//    func filterContentForSearchText(searchText: String, scope: String = "All") {
//        
//        filteredPosts = posts.filter { posts in
//            return posts.title!.lowercaseString.containsString(searchText.lowercaseString)
//        }
// 
//        //tableView.reloadData()
//        
//    }
    
    //MARK: Actions

    @IBAction func popover(sender: AnyObject) {
        
        self.performSegueWithIdentifier("showNotifications", sender: self)
        
    }
    
    @IBAction func showFilters(sender: AnyObject) {
        
        filtersView.hidden = false
        showFiltersBtn.hidden = true
        hideFiltersBtn.hidden = false
        hideFiltersBtn.enabled = true
        showAllBtn.enabled = true
        defisBtn.enabled = true
        astucesBtn.enabled = true
        evenementsBtn.enabled = true
        curiositesBtn.enabled = true
        
    }
    
    @IBAction func showSearchBar(sender: AnyObject) {
        
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        
        locationSearchTable.mapView = mkMapView
        
        let searchBar = resultSearchController.searchBar
        searchBar.placeholder = "Rechercher"
        searchBar.delegate = self
        presentViewController(resultSearchController, animated: true, completion: nil)
        
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
//        searchController.searchResultsUpdater = self
//        searchController.dimsBackgroundDuringPresentation = false
//        definesPresentationContext = true
        
//        searchController.searchBar.placeholder = "Rechercher"
//
//        searchController.hidesNavigationBarDuringPresentation = false
//        self.searchController.searchBar.delegate = self
//        presentViewController(searchController, animated: true, completion: nil)
        
        
    }

    
    
    
    @IBAction func refreshLocation(sender: AnyObject) {
        
        let userLocation = self.location.coordinate;
        //print(userLocation)
        print(self.location)
        
        self.centerMapOnLocation(userLocation)
    }
    
    @IBAction func hideFilters(sender: AnyObject) {
        
        showFiltersBtn.hidden = false
        showFiltersBtn.enabled = true
        filtersView.hidden = true
        
    }
    
    @IBAction func filterPosts(sender: UIButton) {
        print("nome do botao:",sender.tag)
        var showCategory:Int!
        switch sender {
        case showAllBtn:
            showCategory = Post.ALL
            showFiltersBtn.setImage(UIImage(named: "filtros_map"), forState: .Normal)
        case defisBtn:
            showCategory = Post.DEFIS
            showFiltersBtn.setImage(UIImage(named: "filtro_map_desafio"), forState: .Normal)
        case astucesBtn:
            showCategory = Post.ASTUCES
            showFiltersBtn.setImage(UIImage(named: "filtro_map_dica"), forState: .Normal)
        case evenementsBtn:
            showCategory = Post.EVENEMENTS
            showFiltersBtn.setImage(UIImage(named: "filtro_map_evento"), forState: .Normal)
        case curiositesBtn:
            showCategory = Post.CURIOSITE
            showFiltersBtn.setImage(UIImage(named: "filtro_map_curiosidade"), forState: .Normal)
        default:
            showCategory = 5
        }
        
        showFiltersBtn.imageView?.image = UIImage(named: Post.IMG_CATEGORIES[showCategory])
        self.hideFilters(sender);
        
        for annotation in self.clusteringManager.allAnnotations() {
            self.mkMapView.viewForAnnotation(annotation)?.hidden = true
            print("iniciou o loop de cluster annotation")
            //            if showCategory == 5 {
            //                self.mkMapView.viewForAnnotation(annotation)?.hidden = false
            //                continue
            //            }
            
            if annotation.isKindOfClass(PostAnnotation) {
                print("é classe de Post")
                let post: PostAnnotation = annotation as! PostAnnotation
                
                if post.category.integerValue == showCategory {
                    print("coloca como visivel")
                    self.mkMapView.viewForAnnotation(post)?.hidden = false
                }
            }
        }
        
    }

  /*
    @IBAction func filterPosts(sender: UIButton) {
        
        resetMapFilter();
        
        print("nome do botao:",sender.tag)
        
        switch sender {
        case showAllBtn:
            // aqui mostrar todas as categorias
            showCategory = 0
            showFiltersBtn.setImage(UIImage(named: "filtros_map_on"), forState: .Normal)
        case defisBtn:
            showCategory = Post.DEFIS
            showFiltersBtn.setImage(UIImage(named: "filtro_map_desafio"), forState: .Normal)
        case astucesBtn:
            showCategory = Post.ASTUCES
            showFiltersBtn.setImage(UIImage(named: "filtro_map_dica"), forState: .Normal)
        case evenementsBtn:
            showCategory = Post.EVENEMENTS
            showFiltersBtn.setImage(UIImage(named: "filtro_map_evento"), forState: .Normal)
        case curiositesBtn:
            showCategory = Post.CURIOSITE
            showFiltersBtn.setImage(UIImage(named: "filtro_map_curiosidade"), forState: .Normal)
        default:
            showCategory = 5
        }
        
        print(Post.IMG_CATEGORIES[showCategory])
        
        showFiltersBtn.imageView?.image = UIImage(named: Post.IMG_CATEGORIES[showCategory])
        self.hideFilters(sender);
        
        mapFilter()
        
    }
    
    */
    
    func mapFilter() {
        
        if(showCategory != 0 && showCategory < 5 ) {
            for annotation in self.mkMapView.annotations {
                if annotation.isKindOfClass(PostAnnotation) {
                    
                    let post: PostAnnotation = annotation as! PostAnnotation
                    
                    if post.category.integerValue != showCategory {
                        self.mkMapView.viewForAnnotation(post)?.hidden = true
                    }
                }
            }
        }
    }
    
    func resetMapFilter() {
        for annotation in self.clusteringManager.allAnnotations() {
            self.mkMapView.viewForAnnotation(annotation)?.hidden = true
        }
    }
 

    
    func randomLocationsWithCount(count:Int) -> [FBAnnotation] {
        var array:[FBAnnotation] = []
        for _ in 0...count {
            let a:FBAnnotation = FBAnnotation()
            a.coordinate = CLLocationCoordinate2D(latitude: drand48() * 40 - 20, longitude: drand48() * 80 - 40 )
            array.append(a)
        }
        return array
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
        
//        let touchPoint = getstureRecognizer.locationInView(self.mkMapView)
//        let touchMapCoordinate = mkMapView.convertPoint(touchPoint, toCoordinateFromView: mkMapView )
        
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
        //print("passou aqui no método")
        self.location = manager.location!
        //print(self.location)
        //print("-------------------------------")
//        let userLocation = self.location.coordinate;
//        
//        let geocoder = CLGeocoder()
//        geocoder.reverseGeocodeLocation(manager.location!) {
//            (placemarks, error) -> Void in
//            if let placemarks = placemarks as? [CLPlacemark] where placemarks.count > 0 {
//            var placemark = placemarks[0]
//            
//            if let validPlacemark = placemarks?[0]{
//                let placemark = validPlacemark as CLPlacemark;
//                print("placemark")
//                print(String(placemark.name))
//
//            }
//            print(userLocation)
//            }
//        }
        //locationManager.stopUpdatingLocation();
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //print("map controller")
        //print(segue.identifier)
        if segue.identifier == "to_post_detail" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            print(navigationController.viewControllers)
            let postDetailsController:PostDetailViewController = navigationController.viewControllers[0] as! PostDetailViewController
            postDetailsController.post = (sender as! PostAnnotation)
            print("*************************************")
            print((sender as! PostAnnotation))
            print("*************************************")
        } else if segue.identifier == "showNotifications" {
            
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
    
    
    
    
//    
//    func getLatitudeLongitudeLimitsFromMap(mapView: MKMapView) -> [String: Double] {
//        var coord = [String: Double]()
//        
//        let MinLat: Double = mapView.region.center.latitude - (mapView.region.span.latitudeDelta / 2)
//        let MaxLat: Double = mapView.region.center.latitude + (mapView.region.span.latitudeDelta / 2)
//        let MinLon: Double = mapView.region.center.longitude - (mapView.region.span.longitudeDelta / 2)
//        let MaxLon: Double = mapView.region.center.longitude + (mapView.region.span.longitudeDelta / 2)
//        
//        coord["MinLat"] = MinLat
//        coord["MaxLat"] = MaxLat
//        coord["MinLon"] = MinLon
//        coord["MaxLon"] = MaxLon
//        
//        return coord
//    }
    
//    func LoadMap(mapView: MKMapView) {
//        // Get the limits after move or resize the map
//        let coord: [String: Double] = getLatitudeLongitudeLimitsFromMap(mapView)
//        let MinLat: Double = coord["MinLat"]! as Double
//        let MaxLat: Double = coord["MaxLat"]! as Double
//        let MinLon: Double = coord["MinLon"]! as Double
//        let MaxLon: Double = coord["MaxLon"]! as Double
//        var arrAnnotations = [Annotation]()
//        
//        let FilterMinLat = self.posts.filter({
//            if let item: Annotation = $0 {
//                return item.coordinate.latitude > MinLat
//            } else {
//                return false
//            }
//        })
//        
//        let FilterMaxLat = FilterMinLat.filter({
//            if let item : Annotation = $0 {
//                return item.coordinate.latitude < MaxLat
//            } else {
//                return false
//            }
//        })
//        let FilterMinLon = FilterMaxLat.filter({
//            if let item : Annotation = $0 {
//                return item.coordinate.longitude > MinLon
//            } else {
//                return false
//            }
//        })
//        let FilterMaxLon = FilterMinLon.filter({
//            if let item : Annotation = $0 {
//                return item.coordinate.longitude < MaxLon
//            } else {
//                return false
//            }
//        })
//        
//        for post in FilterMaxLon {
//            arrAnnotations.append(post)
//        }
//    
//        // Show in the map only the annotations from that specific region
//        iphoneScaleFactorLatitude = Double(mapView.bounds.size.width / 30)
//        iphoneScaleFactorLongitude = Double(mapView.bounds.size.height / 30)
//    
//        if zoomLevel != mapView.region.span.longitudeDelta {
//            filterAnnotations(mapView, arrAnnotations: arrAnnotations)
//    
//            zoomLevel = mapView.region.span.longitudeDelta
//    
//            CanUpdateMap = true
//        }
//    }
//
//    func filterAnnotations(mapView: MKMapView, arrAnnotations: [MKAnnotation]) {
//        let latDelta: Double = mapView.region.span.longitudeDelta / iphoneScaleFactorLatitude
//        let lonDelta: Double = mapView.region.span.longitudeDelta / iphoneScaleFactorLongitude
//        var shopsToShow = [AnyObject]()
//        var arrAnnotationsNew = [MKAnnotation]()
//    
//        for var i = 0; i < arrAnnotations.count; i++ {
//            let checkingLocation: MKAnnotation = arrAnnotations[i]
//            let latitude: Double = checkingLocation.coordinate.latitude
//            let longitude: Double = checkingLocation.coordinate.longitude
//            var found: Bool = false
//        
//            for tempPlacemark: MKAnnotation in shopsToShow as! [MKAnnotation] {
//                if fabs(tempPlacemark.coordinate.latitude - latitude) < fabs(latDelta) && fabs(tempPlacemark.coordinate.longitude - longitude) < fabs(lonDelta) {
//                    found = true
//                }
//            }
//        
//            if !found {
//                shopsToShow.append(checkingLocation)
//                arrAnnotationsNew.append(checkingLocation)
//            }
//        }
//    
//    
//        // Clean the map
//        for item: MKAnnotation in self.mkMapView.annotations {
//            self.mkMapView.removeAnnotation(item)
//        }
//    
//        // Add new annotations to the map
//        for item: MKAnnotation in arrAnnotationsNew {
//            self.mkMapView.addAnnotation(item)
//        }
//    }
    
//    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
//        NSOperationQueue().addOperationWithBlock({
//            let mapBoundsWidth = Double(self.mkMapView.bounds.size.width)
//            let mapRectWidth:Double = self.mkMapView.visibleMapRect.size.width
//            let scale:Double = mapBoundsWidth / mapRectWidth
//            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mkMapView.visibleMapRect, withZoomScale:scale)
//            self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mkMapView)
//        })
//    }
    
//    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        if CanUpdateMap == true {
//            LoadMap(mapView)
//        }
//    }

//    func zoomToFitMapAnnotations(aMapView: MKMapView) {
//        
//        if aMapView.annotations.count == 0 {
//            
//            return
//        
//        }
//        
//        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
//        topLeftCoord.latitude = -90
//        topLeftCoord.longitude = 180
//        
//        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
//        bottomRightCoord.latitude = 90
//        bottomRightCoord.longitude = -180
//        
//        for annotation: MKAnnotation in self.mkMapView.annotations{
//            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
//            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
//            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
//            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
//        }
//        
//        var region: MKCoordinateRegion = MKCoordinateRegion()
//        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
//        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
//        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
//        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
//        region = aMapView.regionThatFits(region)
//        
//        self.mkMapView.setRegion(region, animated: true)
//    }
    
    func displayPostsInMap() {
        
        let mapBoundsWidth = Double(self.mkMapView.bounds.size.width)
        let mapRectWidth:Double = self.mkMapView.visibleMapRect.size.width
        let scale:Double = mapBoundsWidth / mapRectWidth
        let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mkMapView.visibleMapRect, withZoomScale:scale)
        
        self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mkMapView)
        
        mapFilter()
    }
}

extension MapViewController : FBClusteringManagerDelegate {
    
    func cellSizeFactorForCoordinator(coordinator:FBClusteringManager) -> CGFloat{
        return 1.0
    }
    
}


extension MapViewController : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        
        NSOperationQueue().addOperationWithBlock({
            
            self.displayPostsInMap()
            
        })
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = ""

        if annotation.isKindOfClass(FBAnnotationCluster) {
            
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
            
            return clusterView
            
        }
        
        if annotation.isKindOfClass(PostAnnotation) {
            
            print( "titulo : ", annotation.title)
            let postAnnotation = annotation as! PostAnnotation
            reuseId = "Post"
            
            var postView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
                postView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                postView!.canShowCallout = true
                postView!.image = UIImage(named: String((annotation as! PostAnnotation).getCategoryImageName()))
                postView!.backgroundColor = UIColor.clearColor()
                postView!.calloutOffset = CGPoint(x: -5, y: 5)
            //              postView.rightCalloutAccessoryView = postButton
            
            let imageview = UIImageView(frame: CGRectMake(0, 0, 45, 45))
                imageview.layer.cornerRadius = 22
                imageview.layer.masksToBounds = true
//                imageview.layer.borderWidth = 1
//                imageview.layer.borderColor = UIColor.greenColor().CGColor
                imageview.contentMode = .ScaleAspectFill
            
            if let image : UIImage = ImageUtils.instance.loadImageFromPath(EndpointUtils.USER + "?id=" + String(postAnnotation.owner) + "&avatar=true")! {
                imageview.image = image
            }
            
            postView!.leftCalloutAccessoryView = imageview
            
            return postView
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        NSLog("selecionou")
        let tap = UITapGestureRecognizer(target: self, action: #selector(MapViewController.calloutTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    func calloutTap(sender: UITapGestureRecognizer) {
        
        print(sender)
        print("dentro calloutTap antes isKind")
        if sender.view!.isKindOfClass(MKAnnotationView) {
            let postView : MKAnnotationView = sender.view as! MKAnnotationView
            
            if postView.annotation!.isKindOfClass(PostAnnotation) {
                print("dentro calloutTap depois isKind")
                let post: PostAnnotation = postView.annotation as! PostAnnotation
                print("post ID [AQUI]")
                print(post.id)
                //NSLog(post.getCategoryImageName())
                NSOperationQueue.mainQueue().addOperationWithBlock {
                print("antes");
                self.performSegueWithIdentifier("to_post_detail", sender: post)
                }
            }
            
        }
        print("teste fora")
        
    }
    
}

//extension MapViewController: UISearchResultsUpdating {
//    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        filterContentForSearchText(searchController.searchBar.text!)
//    }
//}