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
            
            let identifier = "myPin"
            
            var annotationView: MKAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) {
                    dequeuedView.annotation = annotation
                    annotationView = dequeuedView
            } else {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                
            }
            
            let postButton: UIButton = UIButton(type: UIButtonType.Custom)
                postButton.addTarget(self, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
            
            //MARK - group image
            //CGFloat lineWidth = 2;
            //CGRect borderRect = CGRectInset(rect, lineWidth * 0.5, lineWidth * 0.5);
            //let imgv = UIImageView(frame: CGRectMake(0, 0, 40, 40))
            //imgv.layer.cornerRadius = 20
            //imgv.backgroundColor = UIColor.blueColor();
            
            print("Image Pin Name : ", annotation.getCategoryImageName(), UIImage(named: annotation.getCategoryImageName()))
            
            annotationView.image = UIImage(named: String(annotation.getCategoryImageName()))
            annotationView.backgroundColor = UIColor.clearColor()
            annotationView.canShowCallout = true
            annotationView.calloutOffset = CGPoint(x: -5, y: 5)
            annotationView.rightCalloutAccessoryView = postButton
            
            let imageview = UIImageView(frame: CGRectMake(0, 0, 45, 45))
            //let imgUtils:ImageUtils = ImageUtils()
            //let image: UIImage = imgUtils.loadImageFromPath(annotation.userImage)!
            //imageview.image = image//resizeImage(image, toTheSize: CGSize(width: 5, height: 5))
            annotationView.leftCalloutAccessoryView = imageview
            
            return annotationView
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