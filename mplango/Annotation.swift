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
    let audio: String
    
    var imageName: String!
    
    init(title: String, locationName: String, audio: String, category: Int, coordinate: CLLocationCoordinate2D, userImage: String) {
        self.title = title
        self.locationName = locationName
        self.category = category
        self.coordinate = coordinate
        self.userImage = userImage
        self.audio = audio
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
        var name:String!
        
        switch self.category {
            case 1:
                name =  "cat_desafio.png"
            case 2:
                name = "cat_atividade.png"
            case 3:
                name = "cat_dica.png"
            case 4:
                name = "cat_ajuda.png"
            default:
                name = "cat_ajuda.png"
        }
        return name
    }
}
