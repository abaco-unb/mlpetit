//
//  ImageUtils.swift
//  mplango
//
//  Created by Bruno on 25/11/15.
//  Copyright © 2015 unb.br. All rights reserved.
//

import Foundation
import UIKit

class ImageUtils {
    
    static let instance = ImageUtils()
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }

    func fileInDocumentsDirectory(filename: String) -> String {
    
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
    
    }

    func saveImage (image: UIImage, path: String ) -> Bool{
    
        let pngImageData = UIImagePNGRepresentation(image)
        //let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
        let result = pngImageData!.writeToFile(path, atomically: true)
    
        return result
    }
    
    func loadImageFromPath(remotePath: String) -> UIImage? {
        
        if let url = NSURL(string: remotePath) {
            if let data = NSData(contentsOfURL: url) {
                print("Loading image from url path: \(remotePath)", terminator: "")
                return UIImage(data: data)
            }        
        } else {
            print("missing image at: \(remotePath)", terminator: "")
        }
        return nil
    }
}