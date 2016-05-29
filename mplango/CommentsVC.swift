//
//  CommentsVC.swift
//  mplango
//
//  Created by Thomas Petit on 10/12/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

class CommentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UIPopoverPresentationControllerDelegate {

    // MARK: Properties
    var indicator:ActivityIndicator = ActivityIndicator()
    
    var comments: Array<Comment>!
    
    var postId:Int!
    
    let basicCellIdentifier = "BasicCell"
    
    @IBOutlet weak var creatingContentView: UIView!
    @IBOutlet weak var comTableView: UITableView!

    @IBOutlet weak var writeTxtView: UITextView!
    @IBOutlet weak var writeHereImage: UIImageView!
    
    @IBOutlet weak var comPicture: UIImageView!
    @IBOutlet weak var picBtn: UIButton!
    
    @IBOutlet weak var removeImage: UIButton!
    
    @IBOutlet weak var recordBtn: UIButton!
    
    @IBOutlet weak var postComBtn: UIButton!

    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.comTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.writeTxtView.delegate = self
        
        print("numero de comentarios: ", self.comments.count)
        
//
//        if comment != nil {
//            writeTxtView.text = comment?.text
//        }
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CommentsVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Para que a view acompanhe o teclado e poder escrever o comentário
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentsVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentsVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        writeTxtView.delegate = self
        
        postComBtn.hidden = true
        removeImage.hidden = true

        comTableView.rowHeight = UITableViewAutomaticDimension
        comTableView.estimatedRowHeight = 200.0

    }
    

    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        
        textViewDidChange(writeTxtView)
        
//        comPicture.image = nil
//        writeTxtView.text = nil
//        postComBtn.hidden = true
//        recordBtn.hidden = false
//        recordBtn.enabled = true
//        writeHereImage.hidden = false
//        removeImage.hidden = true
//        picBtn.hidden = false

    }
    
    // MARK : UITextView functions
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let limitLength = 149
        guard let text = writeTxtView.text else { return true }
        let newLength = text.characters.count - range.length
        
        return newLength <= limitLength
    }
    
    func textViewDidChange(textView: UITextView) {
        
        let text = writeTxtView.text
        
        if text.characters.count >= 1 {
            postComBtn.hidden = false
            postComBtn.enabled = true
            recordBtn.hidden = true
        }
        
        else if text.characters.count < 1 {
            
            if comPicture != nil {
                postComBtn.hidden = false
                recordBtn.hidden = true
                recordBtn.enabled = false
            }
            
            else {
                postComBtn.hidden = true
                recordBtn.hidden = false
                recordBtn.enabled = true
            }
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        writeHereImage.hidden = true
    }
    
    
    // MARK Actions:
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK:- Posting Comment
    @IBAction func postingComment(sender: AnyObject) {
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userId:Int = prefs.integerForKey("id") as Int
        
        let params : [String: String] = [
            "text" : writeTxtView.text,
            "post" : String(self.postId),
            "user": String(userId)
        ]
        
        print("post", String(self.postId), "user", String(userId))
        
        if(comPicture.image != nil) {
            self.postComment(comPicture.image!, params: params)
        } else {
            self.postComment(params)
        }
        
        // Gamification: contar 5 pontos aqui para a ação de postar 1 comentário
        
    }
    
    
    // MARK : Image Picker Process
    
    var picker:UIImagePickerController? = UIImagePickerController()
    var popover:UIPopoverPresentationController? = nil
    
    
    @IBAction func removeImage(sender: AnyObject) {
        
        comPicture.image = nil
        removeImage.hidden = true
        picBtn.hidden = false
        recordBtn.hidden = false
        recordBtn.enabled = true
        
        textViewDidChange(writeTxtView)

        
    }
    
    @IBAction func selectImageFromPhotoLibrary(sender: UIButton) {
        //Hide the keyboard
        
        writeTxtView.resignFirstResponder()
        
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
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(alert, animated: true, completion: nil)
       
        } else {
            popover = UIPopoverPresentationController(presentedViewController: alert, presentingViewController: alert)
            popover?.sourceView = self.view
            popover?.barButtonItem = navigationItem.rightBarButtonItem
            popover?.permittedArrowDirections = .Any
        }
    }
    
    func openCamera() {
        
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(picker!, animated: true, completion: nil)
            } else {
            openGallary()
            }
        }
    
        func openGallary() {

        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(picker!, animated: true, completion: nil)
        } else {
            popover = UIPopoverPresentationController(presentedViewController: picker!, presentingViewController: picker!)
            
            popover?.sourceView = self.view
            popover?.barButtonItem = navigationItem.rightBarButtonItem
            popover?.permittedArrowDirections = .Any
        }
    }
   
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)

        let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        let fixOrientationImage = chosenImage!.fixOrientation()
        comPicture.image = fixOrientationImage
        
        // save image in memory
        self.image = comPicture.image!
        
        picBtn.hidden = true
        removeImage.hidden = false
        postComBtn.hidden = false
        postComBtn.enabled = true
        recordBtn.hidden = true
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("picker cancel.")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func afterPosting(json: JSON) {
        writeTxtView.resignFirstResponder()
        writeTxtView.text = nil
        postComBtn.hidden = true
        recordBtn.hidden = false
        recordBtn.enabled = true
        writeHereImage.hidden = false
        if self.comPicture != nil {
            self.removeImage(self)
        }
        
        var id: Int = 0
        var uId: Int = 0
        
        if let commentId = json["data"]["id"].int {
            id = commentId
        }
        
        if let commentUser = json["data"]["user"]["id"].int {
            uId = commentUser
        }
        
        let comment = Comment(id: id, audio: json["data"]["audio"].stringValue, text: json["data"]["text"].stringValue, image: json["data"]["image"].stringValue, postId: self.postId, created: json["data"]["created"]["date"].stringValue, userId: uId)
        
        comments.append(comment)
        comTableView.reloadData()
        
    }


    func postComment(params: Dictionary<String, String>) {
        Alamofire.request(.POST, EndpointUtils.COMMENT, parameters: params)
            .responseString { response in
                print("Request: \(EndpointUtils.COMMENT)")
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                print("Request: \(request)")
                print("request: \(error)")
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    self.afterPosting(json)
                    
                    
                } else {
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Controller
                        let alertController = UIAlertController(title: "Oops", message: "Tivemos um problema ao tentar criar seu post. Favor tente novamente.", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The post is not okay.")
                            self.indicator.hideActivityIndicator();
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            })
    }
    
    func postComment(image: UIImage, params: Dictionary<String, String>) {
        
        let imageData = image.lowestQualityJPEGNSData
        
        // save image in directory
//        let imgUtils:ImageUtils = ImageUtils()
//        self.imagePath = imgUtils.fileInDocumentsDirectory(self.generateIndexName("post_image", ext: "png"))
//        imgUtils.saveImage(comPicture.image!, path: self.imagePath);

        
        self.indicator.showActivityIndicator(self.view)
        
        // CREATE AND SEND REQUEST ----------
        
        let urlRequest = UrlRequestUtils.instance.urlRequestWithComponents(EndpointUtils.COMMENT, parameters: params, imageData: imageData)
        
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseString { response in
                print("Request: \(EndpointUtils.COMMENT)")
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    self.afterPosting(json)
                } else {
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Controller
                        let alertController = UIAlertController(title: "Ops!", message: "Tivemos um problema ao tentar criar seu comentário. Favor tente novamente.", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The comment is fail.")
                            self.indicator.hideActivityIndicator();
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            })
    }
    
    
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }

    // Table view
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath) as! CommentCell
        cell.comTxtView.text = comments[indexPath.row].text
        cell.dateLabel.text = comments[indexPath.row].created
        cell.profilePicture.image = ImageUtils.instance.loadImageFromPath(EndpointUtils.USER + "?id=" + String(comments[indexPath.row].userId)  + "&avatar=true" )
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
}