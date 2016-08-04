//
//  Post.swift
//  maplango
//
//  Created by Bruno on 02/07/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import Foundation

import MapKit
import Contacts

class PostAnnotation: FBAnnotation{
    let id: Int
    let locationName: String
    let category: NSNumber
    let text: String
    let owner: Int
    
    var ownername:String = ""
    
    
    init(id: Int, title: String, text: String, locationName: String, coordinate: CLLocationCoordinate2D, category: Int, owner: Int) {
        self.id = id
        self.locationName = locationName
        self.category = category
        self.text = text
        self.owner = owner
        super.init()
        
        super.coordinate = coordinate
        super.title = title
        
    }
    
    var subtitle: String? {
        return text
    }
    
    func getLocationStreetAdreessName(coordinate: CLLocationCoordinate2D){
        
    }
    
    func setOwnerName(name:String) {
        self.ownername = name
    }
    
    func getOwnerName() -> String {
        return self.ownername
    }
    
    func getImage(imageId : Int) -> UIImage {
       
        let image: UIImage = ImageUtils.instance.loadImageFromPath(EndpointUtils.IMAGE + "/" + String(imageId) )!
        return image
       
    }
    
    func getOwnerImage() -> UIImage {
        
        let image: UIImage = ImageUtils.instance.loadImageFromPath(EndpointUtils.USER + "?id=" + String( self.owner ) + "&avatar=true" )!
        return image
        
    }
    
    func getAudioUrl() -> String {
        
        return EndpointUtils.POST + "?id=" + self.id.description +  "&audio=true"
        
    }
    
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(CNPostalAddressStreetKey): self.subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    
    func getCategoryImageName() -> String {
        var name:String!
        
        switch self.category {
            
        case Post.DEFIS:
            name =  "cat_defi.png"
        case Post.CURIOSITE:
            name = "cat_question.png"
        case Post.ASTUCES:
            name = "cat_astuce.png"
        case Post.EVENEMENTS:
            name = "cat_evenement.png"
        default:
            name = "clusterSmall.png"
        }
        return name
    }
    
}