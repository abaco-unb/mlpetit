//
//  ProfileVC.swift
//  mplango
//
//  Created by Thomas Petit on 13/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit
import MapKit


class ProfileVC: UIViewController {
    
    var contact: RUser!
    var userId:Int!
    
    var myAnnotations = [PostAnnotation]()
    
    @IBOutlet weak var mkMapView: MKMapView!
    
    let clusteringManager = FBClusteringManager()
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileGender: UIImageView!
    @IBOutlet weak var profileLangLevel: UIImageView!
    @IBOutlet weak var profileNationality: UILabel!
    @IBOutlet weak var profileNumberPosts: UILabel!
    @IBOutlet weak var profileNumberFollowers: UILabel!
    @IBOutlet weak var profileNumberFollowing: UILabel!
    @IBOutlet weak var profileBio: UILabel!
    
    @IBOutlet var followersBtn: UIButton!
    @IBOutlet var followingBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clusteringManager.delegate = self
        
        self.mkMapView.showsUserLocation = true
        self.mkMapView.delegate = self
        self.mkMapView.mapType = MKMapType.Standard
        
        if contact != self.userId {
            
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.backBarButtonItem!.enabled = true
            self.navigationItem.backBarButtonItem!.title = "liste"
            self.navigationItem.rightBarButtonItem = nil
    
            self.navigationItem.title = contact.name
            self.profileNationality.text = contact.nationality
            self.profileBio.text = contact.bio
            
            let image = ImageUtils.instance.loadImageFromPath(contact.image)
            if (!contact.image.isEmpty && image != nil){
                print("image inneer")
                print(image)
                profilePicture.image = image
            }
            else {
                profilePicture.image = UIImage(named: "empty_profile")
            }
            
            if contact.gender == "Homme" {
                self.profileGender.image = UIImage(named:"icon_masc_profile")
            }
            else if contact.gender == "Femme" {
                self.profileGender.image = UIImage(named:"icon_fem_profile")
            }

            if contact.level == User.BEGINNER {
                self.profileLangLevel.image = UIImage(named: "profile_niv1")
            }
            else if contact.level == User.HIGH_BEGINNER {
                self.profileLangLevel.image = UIImage(named: "profile_niv2")
            }
            else if contact.level == User.INTERMEDIATE {
                self.profileLangLevel.image = UIImage(named: "profile_niv3")
            }
            else if contact.level == User.ADVANCED {
                self.profileLangLevel.image = UIImage(named: "profile_niv4")
            }
            else if contact.level == User.MEDIATOR {
                self.profileLangLevel.image = UIImage(named: "profile_nivM")
            }
            
            self.profileNumberFollowers.text = String([contact.followers].count)
            self.profileNumberFollowing.text = String([contact.following].count)
            
            print("+++++++++++++++++++")
                        print(contact.followers)
            print("+++++++++++++++++++")
            
//            self.profileNumberPosts.text = String([contact.posts].count)
            
        } else {
            
            retrieveLoggedUser()
            print("self.userId : ", self.userId)
            self.upServerUser()
            
        }
        
        profilePicture.layer.cornerRadius = 40
        profilePicture.layer.masksToBounds = true
        
    }

    
    func retrieveLoggedUser() {
        
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", userId)
        
    }
    
    func upServerUser() {
        ActivityIndicator.instance.showActivityIndicator(self.view)

        let params : [String: Int] = [
            "id": self.userId
        ]

        //Checagem remota
        Alamofire.request(.GET, EndpointUtils.USER, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                ActivityIndicator.instance.hideActivityIndicator();
                let user = json["data"]
                print(user);
                
                    if let photo = user["image"].string {
                    print("show photo : ", photo)
                        self.profilePicture.image = ImageUtils.instance.loadImageFromPath(EndpointUtils.USER + "?id=" + String( self.userId ) + "&avatar=true")
                    }
                
                    if let username = user["name"].string {
                    print("show name : ", username)
                    self.navigationItem.title = (username)
                    }
                
                    if let nat = user["nationality"].string {
                    print("show nationality : ", nat)
                    self.profileNationality.text = (nat)
                    }
                

                    if let gen = user["gender"].string {
                    print("show gender : ", gen)
                        if gen == "Homme" {
                            self.profileGender.image = UIImage(named: "icon_masc_profile")
                        }
                        else if gen == "Femme" {
                            self.profileGender.image = UIImage(named: "icon_fem_profile")
                        }
                    }
                
                    if let lev = user["level"]["id"].int {
                    print("show level : ", lev)
                        if lev == User.BEGINNER {
                            self.profileLangLevel.image = UIImage(named: "profile_niv1")
                        }
                        else if lev == User.HIGH_BEGINNER {
                            self.profileLangLevel.image = UIImage(named: "profile_niv2")
                        }
                        else if lev == User.INTERMEDIATE {
                            self.profileLangLevel.image = UIImage(named: "profile_niv3")
                        }
                        else if lev == User.ADVANCED {
                            self.profileLangLevel.image = UIImage(named: "profile_niv4")
                        }
                        else if lev == User.MEDIATOR {
                            self.profileLangLevel.image = UIImage(named: "profile_nivM")
                        }
                    }
                
                if let following = user["following"].array {
                    self.profileNumberFollowing.text = String(following.count)
                }
                
                if let followers = user["followers"].array {
                    self.profileNumberFollowers.text = String(followers.count)
                }
                
                if let bio = user["bio"].string {
                    print("show bio : ", bio)
                    self.profileBio.text = (bio)
                }
                
                if let posts = user["posts"].array {
                    
                    self.profileNumberPosts.text = String(posts.count)
                    
                    for post in posts {
                        var postId:Int = 0
                        var latitude:Double  = 0
                        var longitude:Double = 0
                        var category:Int = 0
                        
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

                        let postAnnotation = PostAnnotation(
                            id: postId,
                            title: post["user"]["name"].stringValue,
                            text: post["text"].stringValue,
                            locationName: post["location"].stringValue,
                            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                            category: category,
                            owner: self.userId,
                            time: post["created"].stringValue
                        )
                        self.myAnnotations.append(postAnnotation);
                        
                    }
                    
                    self.clusteringManager.addAnnotations(self.myAnnotations)
                    self.displayPostsInMap()
                    
                }
                
        });
        
    }
    
    @IBAction func unwindSecondView(segue: UIStoryboardSegue) {
        print ("unwindSecondView fired in first view")
        print("self.userId : ", self.userId)
        self.upServerUser()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        print(sender)
        if segue.identifier == "show_followers" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let followersController:ContactViewController = navigationController.viewControllers[0] as! ContactViewController
            
            followersController.navigationItem.title = "Mappé(e)s"
//            followersController.tableView.numberOfRowsInSection([contact.followers].count)
           
            print("+++++++++++++++++++")
//            print(contact.followers)
            print("+++++++++++++++++++")
        }
        
        if segue.identifier == "show_following" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let followingController:ContactViewController = navigationController.viewControllers[0] as! ContactViewController
            
            followingController.navigationItem.title = "Mappeurs"
            
        }
        
    }
    
    func displayPostsInMap() {
        
        let mapBoundsWidth = Double(self.mkMapView.bounds.size.width)
        let mapRectWidth:Double = self.mkMapView.visibleMapRect.size.width
        let scale:Double = mapBoundsWidth / mapRectWidth
        let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mkMapView.visibleMapRect, withZoomScale:scale)
        
        self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mkMapView)

    }

}

extension ProfileVC : FBClusteringManagerDelegate {
    
    func cellSizeFactorForCoordinator(coordinator:FBClusteringManager) -> CGFloat{
        return 1.0
    }
}

extension ProfileVC : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        
        NSOperationQueue().addOperationWithBlock({
            
            self.displayPostsInMap()
            
        })
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        print("entrou no mapa")
        
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
            imageview.layer.borderWidth = 1
            imageview.layer.borderColor = UIColor.greenColor().CGColor
            
            if let image : UIImage = ImageUtils.instance.loadImageFromPath(EndpointUtils.USER + "?id=" + String(postAnnotation.owner) + "&avatar=true")! {
                imageview.image = image
            }
            
            postView!.leftCalloutAccessoryView = imageview
            
            return postView
        }
        
        return nil
    }
    
}
