//
//  TextActivityVC.swift
//  mplango
//
//  Created by Thomas Petit on 08/06/2016.
//  Copyright © 2016 unb.br. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

class TextActivityVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    //MARK: Properties
    
    var activity: Test? = nil
    
    // deixei essas variáveis aqui apenas para não dar erro no processo de upload da atividade com o alamofire
    var recordedAudio:RecordedAudio!
    var audioPath: String = ""
    
    var imagePath: String = ""
    var image:UIImage!
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var sentBtn: UIBarButtonItem!
    
    //Outlets para o mediador
    @IBOutlet weak var evalView: UIView!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var redoBtn: UIButton!
    
    //Outlets para o texto
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var maxLenghtLabel: UILabel!
    @IBOutlet weak var writeHereImage: UIImageView!
    
    //Outlets para a foto
    @IBOutlet weak var addPicture: UIButton!
    @IBOutlet weak var removeImage: UIButton!
    @IBOutlet weak var photoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scroll.contentSize.height = 200
        
//        checkValidChange()
                
        // Keyboard stuff.
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(TextActivityVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(TextActivityVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)

        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TextActivityVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        
        let text = textView.text
        if text.characters.count >= 1 {
            writeHereImage.hidden = true
        }
        else {
            writeHereImage.hidden = false
        }
    }
    
    //MARK: UIScrollView moves up (textField) when keyboard appears
    
    func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        var contentInset:UIEdgeInsets = self.scroll.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scroll.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsetsZero
        self.scroll.contentInset = contentInset
    }
    
    
    func checkValidChange() {
        // Disable the Save button if the text field is empty.
        let text = textView.text ?? ""
        sentBtn.enabled = !text.isEmpty
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"  // Recognizes enter key in keyboard
        {
            textView.resignFirstResponder()
            return false
        }
        let limitLength = 149
        let text : String = textView.text
        let newLength = text.characters.count - range.length
        return newLength <= limitLength
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        writeHereImage.hidden = true
        sentBtn.enabled = false
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        checkValidChange()
    }
    
    
    // MARK: Actions
    
    @IBAction func removeImage(sender: AnyObject) {
        self.image = nil
        photoImage.image = nil
        addPicture.hidden = false
        addPicture.enabled = true
        removeImage.hidden = true
    }
    
    // MARK : Image Picker Process
    
    var picker:UIImagePickerController? = UIImagePickerController()
    var popover:UIPopoverPresentationController? = nil
    
    @IBAction func selectImageFromPhotoLibrary(sender: UIButton) {
        
//        if textView != nil {
//            textView.resignFirstResponder()
//        }
        
        let alert:UIAlertController=UIAlertController(title: "Choisir une image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cameraAction = UIAlertAction(title: "Caméra", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallerie", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        picker?.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            popover = UIPopoverPresentationController(presentedViewController: alert, presentingViewController: alert)
            popover?.sourceView = self.view
            popover?.sourceRect = addPicture.frame
            popover?.permittedArrowDirections = .Any
        }
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(picker!, animated: true, completion: nil)
        } else {
            openGallary()
        }
    }
    
    func openGallary()
    {
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(picker!, animated: true, completion: nil)
        } else {
            popover = UIPopoverPresentationController(presentedViewController: picker!, presentingViewController: picker!)
            popover?.sourceView = self.view
            popover?.sourceRect = addPicture.frame
            popover?.permittedArrowDirections = .Any
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        addPicture.hidden = true
        removeImage.hidden = false
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        let fixOrientationImage = chosenImage!.fixOrientation()
        photoImage.image = fixOrientationImage
        
        self.image = photoImage.image!
        
        // Custom the visual identity of Image View
        photoImage.layer.cornerRadius = 10
        photoImage.layer.masksToBounds = true

    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        print("picker cancel.")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: Post Actions
    
    @IBAction func send(sender: AnyObject) {
        
//        self.sendActivity()
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func sendActivity(){
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userId:Int = prefs.integerForKey("id") as Int
        print("enviando esse post...")
        print((textView.text != nil || textView.text != "") ? textView.text : "nada informado")
        print(userId)
        
        let text = (textView.text != nil || textView.text != "") ? textView.text : ""
        
        //        tagsView.resolveHashTags()
        let params : [String: String] = [
            "text" : text,
            "user": String(userId)
        ]
        
        if(self.image != nil || self.audioPath != "") {
            print("com imagem")
            self.save(false, params: params)
        } else {
            print("sem imagem")
            self.save(params)
        }
    }
    
    func save(params: Dictionary<String, String>) {
        Alamofire.request(.POST, EndpointUtils.POST, parameters: params)
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                ActivityIndicator.instance.hideActivityIndicator();
                if (error == nil) {
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("go_to_points_notification", sender: self)
                    }
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Controller
                        let alertController = UIAlertController(title: "Oops", message: "Tivemos um problema ao tentar criar seu post. Favor tente novamente.", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The post is not okay.")
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            })
    }
    
    func save(upload: Bool, params: Dictionary<String, String>) {
        print(0)
        var imageData:NSData!
        print(1)
        if self.image != nil {
            print(2)
            imageData = image.lowestQualityJPEGNSData
        }
        print(3)
        ActivityIndicator.instance.showActivityIndicator(self.view)
        
        // CREATE AND SEND REQUEST ----------
        let urlRequest = self.urlRequestWithComponents(EndpointUtils.POST, parameters: params, data: false)
        print(4)
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                ActivityIndicator.instance.hideActivityIndicator();
                if (error == nil) {
                    print("ok post notification")
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("go_to_points_notification", sender: self)
                    }
                } else {
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Controller
                        let alertController = UIAlertController(title: "Oops", message: "Tivemos um problema ao tentar criar seu post. Favor tente novamente.", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The post is not okay.")
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            })
    }
    
    
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, data:Bool) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        if self.image != nil {
            let imageData:NSData = image.lowestQualityJPEGNSData
            // add image
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData(imageData)
            
        }
        if audioPath != "" {
            print("soundData")
            let soundData = NSData(contentsOfURL: recordedAudio.filePathUrl)
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"audio\"; filename=\"audio.m4a\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData(soundData!)
            
        } else {
            print("error: append audio data")
        }
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    
    // MARK: Others
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(scroll, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(scroll, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    


}