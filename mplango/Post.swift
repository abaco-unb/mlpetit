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

class Post: NSObject, MKAnnotation {
    let title: String
    let locationName: String
    let category: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, category: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.category = category
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String {
        return locationName
    }
    
    // annotation callout info button opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(kABPersonAddressStreetKey): subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    
    func pinColor() -> MKPinAnnotationColor  {
        switch category {
        case "Challenge":
            return .Red
        case "Default":
            return .Purple
        default:
            return .Green
        }
    }
}
