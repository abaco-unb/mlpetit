//
//  PostViewController.swift
//  mplango
//
//  Created by Bruno Santos Ferreira on 16/08/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON
import CoreLocation


class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIAlertViewDelegate, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate {
    
    //MARK: Properties

    var post: PostAnnotation? = nil
    
    // Dados da coordenada do usuário
    var locationManager = CLLocationManager()
    var location:CLLocation!
    var address:String = ""
    var latitude:String = ""
    var longitude:String = ""
    
    var videoPath: String = ""
    var imagePath: String = ""
    var tags = [String]()
    var points = 0
    var category = 0
    
    var userBadge:Int!
    var userId: Int!
    
    
    var image:UIImage!
    
    @IBOutlet weak var continueBtn: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    //Outlets para os tags e o texto
    @IBOutlet weak var textPostView: UITextView!
    @IBOutlet weak var maxLenghtLabel: UILabel!
    @IBOutlet weak var checkTextPost: UILabel!
    @IBOutlet weak var writeHereImage: UIImageView!
    @IBOutlet weak var checkTag1: UILabel!
    @IBOutlet weak var checkTag2: UILabel!
    @IBOutlet weak var checkTag3: UILabel!
    
    
    @IBOutlet weak var iconAudio: UIImageView!
    @IBOutlet weak var labelRecording: UILabel!
    //Outlets para o som
    @IBOutlet weak var backgroundRecord: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    //@IBOutlet weak var slowBtn: UIButton!
    @IBOutlet weak var audioSlider: UISlider!
    //@IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var checkAudio: UILabel!
    @IBOutlet weak var lineAudio: UIView!
    
    //Outlets para a foto
    @IBOutlet weak var addPicture: UIButton!
    @IBOutlet weak var removeImage: UIButton!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var checkImage: UILabel!
    
    //Outlets para o vídeo
    @IBOutlet weak var addVideo: UIButton!
    @IBOutlet weak var removeVideo: UIButton!
    @IBOutlet weak var videoView: UIImageView!
    @IBOutlet weak var checkVideo: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if category == Optional(1) {
            let defi = UIImage(named: "cat_defi_bar")
            let imageView = UIImageView(image:defi)
            self.navigationItem.titleView = imageView
            
        } else if category == Optional(2) {
            let question = UIImage(named: "cat_question_bar")
            let imageView = UIImageView(image:question)
            self.navigationItem.titleView = imageView
            
        } else if category == Optional(3) {
            let astuce = UIImage(named: "cat_astuce_bar")
            let imageView = UIImageView(image:astuce)
            self.navigationItem.titleView = imageView
        
        } else if category == Optional(4) {
            let evenement = UIImage(named: "cat_evenement_bar")
            let imageView = UIImageView(image:evenement)
            self.navigationItem.titleView = imageView
        }
        
        self.playButton.hidden = true
        self.stopBtn.hidden = true
        
        locationManager.requestAlwaysAuthorization()
        //get geo location data
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
        } else {
            NSLog("Serviço de localização indisponível")
        }
        
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
                            icon: self.iconAudio,
                            check: self.checkAudio,
                            label: self.labelRecording,
                            btnRecorder: self.recordButton)
                    }
                    
                }
                
            });
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        //tagsView.delegate = self
        textPostView.delegate = self
        
        //confirmButton.hidden = true
        continueBtn.enabled = true
        removeImage.hidden = true
        removeVideo.hidden = true
        
        // Custom the visual identity of Image View
        photoImage.layer.cornerRadius = 10
        photoImage.layer.masksToBounds = true
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        //let aSelector : Selector = "touchOutsideTextField"
        //let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        //tapGesture.numberOfTapsRequired = 1
        //view.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews();
        self.scrollView.contentSize.height = 800;
    }
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        
        let text = textPostView.text
        
        if text.characters.count >= 1 {
            writeHereImage.hidden = true
        }
            
        else {
            writeHereImage.hidden = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location Manager")
        locationManager.stopUpdatingLocation();
        
        self.location = manager.location!
        let userLocation:CLLocationCoordinate2D = manager.location!.coordinate
        
        self.latitude = String(userLocation.latitude);
        self.longitude = String(userLocation.longitude);
        
        print("locations = \(self.latitude) \(self.longitude)")
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(manager.location!) {
            (placemarks, error) -> Void in
            
            if let validPlacemark = placemarks?[0]{
                let placemark = validPlacemark as CLPlacemark;
                self.address = String(placemark.name!) + ", " + String(placemark.locality!)
                
            }
        }
        
    }
    
    
//    func checkValidChange() {
//        // Disable the Save button if the text field is empty.
//        let text = userName.text ?? ""
//        let text2 = userNation.text ?? ""
//        let text3 = userBio.text ?? ""
//        
//        if (!text.isEmpty) {
//            confirmEditProf.enabled = true
//            
//        } else if (!text2.isEmpty) {
//            confirmEditProf.enabled = true
//            
//        } else if (!text3.isEmpty) {
//            confirmEditProf.enabled = true
//            
//        } else {
//            confirmEditProf.enabled = false
//        }
//    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"  // Recognizes enter key in keyboard
        {
            textPostView.resignFirstResponder()
            return false
        }
        
        let limitLength = 149
        
        let char = text.cStringUsingEncoding(NSUTF8StringEncoding)!
        
        //if (textView == tagsView) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -60) {
                resolveHashTags();
            }
            
            //return true;
        //}
        
        let text : String = textPostView.text
        
        let newLength = text.characters.count - range.length
        maxLenghtLabel.textColor = UIColor.darkGrayColor()
        maxLenghtLabel.text = String(newLength)
        
        if (newLength > 139 && newLength <= 149) {
            maxLenghtLabel.textColor = UIColor.redColor()
        }
        if(newLength == 10) {
            //set text as checked
//            checkOn(checkTextPost)
            checkTextPost.textColor = UIColor(hex: 0x43A047)
            checkTextPost.font = UIFont.boldSystemFontOfSize(15)

        }
        
        return newLength <= limitLength
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        writeHereImage.hidden = true
    }
    
    func touchOutsideTextField(){
        NSLog("touchOutsideTextField")
        self.view.endEditing(true)
        textPostView.resolveHashTags();
        
    }
    
    func checkOn() {
//        let checkOn = UIImage(named: "check_on.png");
//        imageCheck.image = checkOn
//        print("passou aqui", imageCheck.image)
    }
    
    // MARK: Actions
    
    @IBAction func removeImage(sender: AnyObject) {
 
        self.image = nil
        self.points -= GamificationRules.IMAGE_TOTAL_POINTS;
        
        checkImage.textColor = UIColor.grayColor()
        checkImage.font = UIFont.boldSystemFontOfSize(12)
        
        photoImage.image = nil
        addPicture.hidden = false
        addPicture.enabled = true
        removeImage.hidden = true
    }
    
    @IBAction func removeVideo(sender: AnyObject) {
        videoView.image = nil
        addVideo.hidden = false
        addVideo.enabled = true
        removeVideo.hidden = true
    }
    
    // MARK : Image Picker Process
    
    var picker:UIImagePickerController? = UIImagePickerController()
    var popover:UIPopoverPresentationController? = nil
    
    @IBAction func selectImageFromPhotoLibrary(sender: UIButton) {
        //Hide the keyboard
        
        textPostView.resignFirstResponder()
        
        let alert:UIAlertController=UIAlertController(title: "Choisir une image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cameraAction = UIAlertAction(title: "Caméra", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallerie", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openGallery()
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
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            openGallery()
        }
    }
    
    func openGallery()
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
        self.points += GamificationRules.IMAGE_TOTAL_POINTS;
        //set image as checked
//        checkOn(checkImage)
        checkImage.textColor = UIColor(hex: 0x43A047)
        checkImage.font = UIFont.boldSystemFontOfSize(15)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        print("picker cancel.")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: Audio Process
    
    @IBAction func playAudio(sender: UIButton) {
        AudioHelper.instance.play(sender)
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        AudioHelper.instance.stop(sender)
    }
    
    @IBAction func changeAudioTime(sender: UISlider) {
        AudioHelper.instance.changeAudioTime()
        
    }
    
    //MARK: Post Actions
    
    @IBAction func savePost(sender: AnyObject) {
        
        //New Alert Controller for post confirmation
        let alertController = UIAlertController(title: "Confirmer ?", message: "Tu confirmes la publication de ton post ?", preferredStyle: .Alert)
        
        let agreeAction = UIAlertAction(title: "Oui, je confirme", style: .Default) { (action) -> Void in
            self.confirmSavePost()
        }
        
        let disagreeAction = UIAlertAction(title: "Non, pas encore", style: .Default) { (action) -> Void in
            print("Post is not confirmed")
        }
        
        alertController.addAction(agreeAction)
        alertController.addAction(disagreeAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func confirmSavePost (){
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userId:Int = prefs.integerForKey("id") as Int
        let text = (textPostView.text != nil || textPostView.text != "") ? textPostView.text : ""
        
        self.points += ((tags.count + GamificationRules.TEXT_TOTAL_POINTS) + AudioHelper.instance.points)
        
        print( "points : " + String(points) )
        
        let params : [String: String] = [
            "text" : text,
            "location" : self.address,
            "latitude" : String(self.latitude),
            "longitude" : String(self.longitude),
            "category" : String(self.category),
            "points"   : String(self.points),
            "user": String(userId)
        ]
        
        if(self.image != nil || (self.userBadge >= 1 && AudioHelper.instance.audioPath != "")) {
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
//        var imageData:NSData!
//        if self.image != nil {
//            imageData = image.lowestQualityJPEGNSData
//        }
        ActivityIndicator.instance.showActivityIndicator(self.view)
        
        // CREATE AND SEND REQUEST ----------
        let urlRequest = self.urlRequestWithComponents(EndpointUtils.POST, parameters: params, data: false)
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
    
    @IBAction func cancelPost(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func resolveHashTags(){
        // turn string in to NSString
        let nsText:NSString = textPostView.text
        
        // this needs to be an array of NSString.  String does not work.
        let words = nsText.componentsSeparatedByString(" ")
        
        // you can't set the font size in the storyboard anymore, since it gets overridden here.
        let attrs = [
            NSFontAttributeName : UIFont.systemFontOfSize(17.0)
        ]
        
        // you can staple URLs onto attributed strings
        let attrString = NSMutableAttributedString(string: nsText as String, attributes:attrs)
        
        // tag each word if it has a hashtag
        for word in words {
            print(word);
            // found a word that is prepended by a hashtag!
            // homework for you: implement @mentions here too.
            if word.hasPrefix("#") {
                
                // a range is the character position, followed by how many characters are in the word.
                // we need this because we staple the "href" to this range.
                let matchRange:NSRange = nsText.rangeOfString(word as String)
                
                // convert the word from NSString to String
                // this allows us to call "dropFirst" to remove the hashtag
                
                // drop the hashtag
                let stringifiedWord = String(word.characters.dropFirst())               // check to see if the hashtag has numbers.
                // ribl is "#1" shouldn't be considered a hashtag.
                let digits = NSCharacterSet.decimalDigitCharacterSet()
                
                if (stringifiedWord.rangeOfCharacterFromSet(digits) != nil) {
                    // hashtag contains a number, like "#1"
                    // so don't make it clickable
                } else {
                    
                    if let _ = tags.indexOf(stringifiedWord) {
                        print("já adicionado")
                    } else {
                        if stringifiedWord != "" {
                            tags.append(stringifiedWord)
                        }
                        //set tags as checked
//                        self.checkOn(checkTextPost)
                        checkTag1.textColor = UIColor(hex: 0x43A047)
                        checkTag1.font = UIFont.boldSystemFontOfSize(12)
                        checkTag1.text = "+ " + String(tags.count) + " (#)"
                        
                    }
                    
                    // set a link for when the user clicks on this word.
                    // it's not enough to use the word "hash", but you need the url scheme syntax "hash://"
                    // note:  since it's a URL now, the color is set to the project's tint color
                    attrString.addAttribute(NSLinkAttributeName, value: "hash:\(stringifiedWord)", range: matchRange)
                }
            }
        }
        
        // we're used to textView.text
        // but here we use textView.attributedText
        // again, this will also wipe out any fonts and colors from the storyboard,
        // so remember to re-add them in the attrs dictionary above
        
        textPostView.attributedText = attrString
    }

    
    // MARK: Others
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Set navigation bar background colour
        self.navigationController!.navigationBar.barTintColor = UIColor(hex: 0x3399CC)
        
        // Set navigation bar title text colour
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        recordButton.enabled = true
    }
    
    func displayAudioFunction( show : Bool) {
        
        self.iconAudio.hidden = !show
        self.labelRecording.hidden = !show
        self.backgroundRecord.hidden = !show
        self.recordButton.hidden = !show
        self.checkAudio.hidden = !show
        self.lineAudio.hidden = !show

    }
    
    func retrieveLoggedUserInfo() -> Int {
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userBadge = prefs.integerForKey("badge") as Int
        self.userId =  prefs.integerForKey("id") as Int
        return self.userId
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "go_to_points_notification" {
            let rewardController:RewardViewController = segue.destinationViewController as! RewardViewController
            print("prepareForSegue")
            print( "points : " + String(points) )
            rewardController.points = points
        }
    }
}