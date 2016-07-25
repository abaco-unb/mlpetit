//
//  ImageUtils.swift
//  mplango
//
//  Created by Bruno on 25/11/15.
//  Copyright © 2015 unb.br. All rights reserved.
//

import Foundation
import UIKit

class ImageUtils : NSObject {
    
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

        if let image : UIImage = NSCache.sharedInstance.objectForKey(remotePath) as? UIImage {
            print("imagem recuperado do cache : " + remotePath)
            return image
            
        } else {
            if let url = NSURL(string: remotePath) {
                print( "3" )
                if let data = NSData(contentsOfURL: url) {
                    print("imagem recuperado sem cache : " + remotePath)
                    let img: UIImage = UIImage(data: data)!
                    NSCache.sharedInstance.setObject(img, forKey: remotePath)
                    return img
                }
            } else {
                print("imagem não pode ser recuperada sem cache : " + remotePath)
            }
        
            return nil
        }
    }
}