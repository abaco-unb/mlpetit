//
//  Post.swift
//  maplango
//
//  Created by Bruno on 02/07/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import Foundation

import MapKit
import AddressBook

class Annotation: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let category: NSNumber
    let coordinate: CLLocationCoordinate2D
    let userImage: String
    let entity: Post?
    
    var imageName: String!
    
    init(title: String, locationName: String, category: NSNumber, coordinate: CLLocationCoordinate2D, userImage: String, entity: Post?) {
        self.title = title
        self.locationName = locationName
        self.category = category
        self.coordinate = coordinate
        self.userImage = userImage
        self.entity = entity
        
        super.init()
    }
    
    /**
    * GET STREET ADDRESS NAME
    */
    func getLocationStreetAdreessName(coordinate: CLLocationCoordinate2D){
        
    }
    
    var subtitle: String? {
        return locationName
    }
    
    // annotation callout info button opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(kABPersonAddressStreetKey): subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    
    func getCategoryImageName() -> String {
        switch category {
        case 1:
            return "cat1.png"
        case 2:
            return "cat2.png"
        default:
            return "cat3.png"
        }
    }
    
    func pinColor() -> MKPinAnnotationColor  {
        switch category {
        case 1:
            return .Red
        case 2:
            return .Purple
        default:
            return .Green
        }
    }
}
