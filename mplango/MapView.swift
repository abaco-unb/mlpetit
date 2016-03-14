//
//  VCMapView.swift
//  maplango
//
//  Created by Bruno on 02/07/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import Foundation

import MapKit

extension MapViewController {
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {

        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }

        if let annotation = annotation as? Annotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.pinColor = annotation.pinColor()
                
                
                //MARK - group image
                
                //CGFloat lineWidth = 2;
                //CGRect borderRect = CGRectInset(rect, lineWidth * 0.5, lineWidth * 0.5);
                let imgv = UIImageView(frame: CGRectMake(0, 0, 40, 40))
                imgv.layer.cornerRadius = 20
                imgv.backgroundColor = UIColor.blueColor();
                
                let image:UIImage = UIImage(named: annotation.getCategoryImageName())!
                view.image = image
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                
                let rightButton: AnyObject = UIButton(type: UIButtonType.InfoLight)
                rightButton.addTarget(self, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
                
                view.rightCalloutAccessoryView = rightButton as! UIView
                
                let imageview = UIImageView(frame: CGRectMake(0, 0, 45, 45))
                //imageview.image = annotation.userImage
                view.leftCalloutAccessoryView = imageview
                
            }
            return view
        }
        return nil
    }
    
    func resizeImage(image:UIImage, toTheSize size:CGSize)-> UIImage{
        let scale = CGFloat(max(size.width/image.size.width,
            size.height/image.size.height))
        let width:CGFloat  = image.size.width * scale
        let height:CGFloat = image.size.height * scale;
        
        let rr:CGRect = CGRectMake( 0, 0, width, height);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.drawInRect(rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage
    }
    
    func mapView(mapView map: MKMapView!, annotationView view: MKAnnotationView!,
        calloutAccessoryControlTapped control: UIControl!) {
            let location = view.annotation as! Annotation
            //let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            //location.mapItem().openInMapsWithLaunchOptions(launchOptions)
//            print(location.entity, terminator: "")
            
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.blueColor()
            circle.fillColor = UIColor(red: 0, green: 0, blue: 255, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        } else {
            return nil
        }
    }
    
}