//
//  CarnetAddVC.swift
//  mplango
//
//  Created by Thomas Petit on 06/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON


class CarnetAddVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIAlertViewDelegate, UIPopoverPresentationControllerDelegate, AVAudioRecorderDelegate {
    
    //MARK: Properties
    
    var indicator:ActivityIndicator = ActivityIndicator()
    var item : String? = nil

    
    var audioPlayer: AVAudioPlayer!
    var recordedAudio:RecordedAudio!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var audioPath: String = ""
    
    var userBadge:Int!
    var userId: Int!
    
    var myImage = "profile.png"
    var imagePath: String = ""
    var image: UIImage!
        
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //Outlets para o texto
    @IBOutlet var wordTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var maxLenghtLabel: UILabel!
    @IBOutlet weak var writeHereImage: UIImageView!
    
    //Outlets para o audio
    @IBOutlet weak var backgroundRecord: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var labelRecord: UILabel!
    @IBOutlet weak var iconRecord: UIImageView!
    @IBOutlet weak var checkAudioFake: UILabel!
    @IBOutlet weak var lineRecord: UIView!

    
    //Outlets para a foto
    @IBOutlet var photoImage: UIImageView!
    @IBOutlet weak var addPicture: UIButton!
    @IBOutlet weak var removeImage: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        scrollView.contentSize.height = 300

        removeImage.hidden = true
        
        // Enable the Save button only if the text field has a valid Word name
        checkValidWordName()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CarnetAddVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        wordTextField.delegate = self
        descTextView.delegate = self
        
//        if item != nil {
//            wordTextField.text = item.word
//        }
        
        self.displayAudioFunction(false)
        
        ActivityIndicator.instance.showActivityIndicator(self.view)
        Alamofire.request(.GET, EndpointUtils.USER, parameters: ["id" : retrieveLoggedUserInfo()])
            .responseSwiftyJSON({ (request, response, json, error) in
                ActivityIndicator.instance.hideActivityIndicator()
                let user = json["data"]
                
                if let badgeRef = user["badge"].int {
                    print("badgeRef")
                    print(badgeRef)
                    self.userBadge = badgeRef
                    if badgeRef >= 1 {
                        self.displayAudioFunction(true)
                        AudioHelper.instance._init(self.backgroundRecord,
                            icon: self.iconRecord,
                            check: self.checkAudioFake,
                            label: self.labelRecord,
                            btnRecorder: self.recordButton)
                    }
                }
                
            });
        
        

        
        // Custom the visual identity of Text Fields
        wordTextField.attributedPlaceholder =
            NSAttributedString(string: "Entrer un nom (obligatoire)", attributes:[NSForegroundColorAttributeName : UIColor.lightGrayColor()])
        
        // Custom the visual identity of Image View
        photoImage.layer.cornerRadius = 10
        photoImage.layer.masksToBounds = true
        
        // Custom the visual identity of audio player's background
        backgroundRecord.layer.borderWidth = 1
        backgroundRecord.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        backgroundRecord.layer.cornerRadius = 15
        backgroundRecord.layer.masksToBounds = true
        
    }
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        
        let text = descTextView.text
        
        if text.characters.count >= 1 {
            writeHereImage.hidden = true
        } else {
            writeHereImage.hidden = false
        }
    }
  
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"  // Recognizes enter key in keyboard
        {
            descTextView.resignFirstResponder()
            return false
        }
        
        let limitLength = 149
        guard let text = descTextView.text else { return true }
        let newLength = text.characters.count - range.length
        
        maxLenghtLabel.text = String(newLength)
        
        if (newLength > 139) {
            maxLenghtLabel.textColor = UIColor.redColor()
        }
        else if (newLength < 140) {
            maxLenghtLabel.textColor = UIColor.darkGrayColor()
        }
        return newLength <= limitLength
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        writeHereImage.hidden = true
    }
    
    //MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK : Image Picker Process
    
    var picker:UIImagePickerController? = UIImagePickerController()
    var popover:UIPopoverPresentationController? = nil
    
    @IBAction func removeImage(sender: AnyObject) {
        
        self.image = nil
        photoImage.image = nil
        addPicture.hidden = false
        addPicture.enabled = true
        removeImage.hidden = true
        
    }
    
    @IBAction func selectImageFromPhotoLibrary(sender: UIButton) {
        //Hide the keyboard
        
        wordTextField.resignFirstResponder()
        descTextView.resignFirstResponder()
        
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
        }
        else
        {
            popover = UIPopoverPresentationController(presentedViewController: alert, presentingViewController: alert)
            popover?.sourceView = self.view
            popover?.sourceRect = addPicture.frame
            popover?.permittedArrowDirections = .Any
            
        }
        
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            openGallary()
        }
    }
    
    func openGallary()
    {
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
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

    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        print("picker cancel.")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Item Carnet Process
    
    
    @IBAction func saveItem(sender: AnyObject) {
        ////recupera o id da sessão
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userId:Int = prefs.integerForKey("id") as Int
        print("salvando uma nota")
        print(self.wordTextField.text)
        print(self.descTextView.text)
        print(self.imagePath)
        print(self.audioPath)
        print(userId)
        
        let params : [String: String] = [
            "word": self.wordTextField.text!,
            "text": self.descTextView.text,
            "user": String(userId)
        ]
        
        if self.image != nil  || (self.userBadge >= 1 && AudioHelper.instance.audioPath != "") {
            self.saveNote(false, params: params)
        } else {
            self.saveNote(params)
        }
    }

    func saveNote(params: Dictionary<String, String>) {
        
        self.indicator.showActivityIndicator(self.view)
        
        Alamofire.request(.POST, EndpointUtils.CARNET, parameters: params)
            .responseString { response in
                print("Success POST: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }
            .responseSwiftyJSON({ (request, response, json, error) in
                print("Request POST: \(request)")
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("go_to_carnet", sender: self)
                    }
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Ccontroller
                        let alertController = UIAlertController(title: "Oops", message: "Tivemos um problema ao tentar criar seu item. Favor tente novamente.", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The item is not okay.")
                            self.indicator.hideActivityIndicator();
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
        })
    }
    
    func saveNote(upload: Bool, params: Dictionary<String, String>) {
        
//        var imageData:NSData!
//        if self.image != nil {
//            imageData = self.image.lowestQualityJPEGNSData
//        }
        ActivityIndicator.instance.showActivityIndicator(self.view)
        
//        // save image in directory
//        let imgUtils:ImageUtils = ImageUtils()
//        self.imagePath = imgUtils.fileInDocumentsDirectory(self.generateIndexName("note_image", ext: "png"))
//        ImageUtils.instance.saveImage(self.photoImage.image!, path: self.imagePath);
        
        // CREATE AND SEND REQUEST ----------
        let urlRequest = self.urlRequestWithComponents(EndpointUtils.CARNET, parameters: params, data: false)
        
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
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        
                        self.performSegueWithIdentifier("go_to_carnet", sender: self)
                    }
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Ccontroller
                        let alertController = UIAlertController(title: "Oops", message: "Tivemos um problema ao tentar criar seu item. Favor tente novamente.", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The item is not okay.")
                            self.indicator.hideActivityIndicator();
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
        if AudioHelper.instance.audioPath != "" {
            print(AudioHelper.instance.audioPath)
            print(AudioHelper.instance.recordedAudio.filePathUrl)
            
            print("soundData")
            let soundData = NSData(contentsOfURL: AudioHelper.instance.recordedAudio.filePathUrl)
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
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveBtn.enabled = false
    }
 
    func checkValidWordName() {
        // Disable the Save button if the text field is empty.
        let text = wordTextField.text ?? ""
        saveBtn.enabled = !text.isEmpty
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidWordName()
        navigationItem.title = wordTextField.text
    }
    
    func displayAudioFunction( show : Bool) {
        
        self.iconRecord.hidden = !show
        self.labelRecord.hidden = !show
        self.backgroundRecord.hidden = !show
        self.recordButton.hidden = !show
        self.lineRecord.hidden = !show
        
    }
    
    func retrieveLoggedUserInfo() -> Int {
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userBadge = prefs.integerForKey("badge") as Int
        self.userId =  prefs.integerForKey("id") as Int
        return self.userId
    }
    

    // MARK: - Navigation
//    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if(segue.identifier == "go_to_carnet"){
            let tabVC = segue.destinationViewController as! UITabBarController
            tabVC.selectedIndex = 3
        }
    }
}
