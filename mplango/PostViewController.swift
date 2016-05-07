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


class PostViewController: UIViewController, AVAudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIAlertViewDelegate, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate {
    
    
    //MARK: Properties
    
    var indicator:ActivityIndicator = ActivityIndicator()
    var post: PostAnnotation? = nil
    
    var audioPlayer: AVAudioPlayer!
    var recordedAudio:RecordedAudio!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    // Dados da coordenada do usuário
    var locationManager = CLLocationManager()
    var location:CLLocation!
    var address:String = ""
    var latitude:String = ""
    var longitude:String = ""
    
    
    var videoPath: String = ""
    var audioPath: String = ""
    var imagePath: String = ""
    var tags = [String]()
    var points = 0
    var category = 0
    
    var image:UIImage!
    
    
   
    @IBOutlet weak var continueBtn: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    //Outlets para os tags e o texto
    @IBOutlet weak var textPostView: UITextView!
    @IBOutlet weak var maxLenghtLabel: UILabel!
    @IBOutlet weak var checkTextPost: UIImageView!
    @IBOutlet weak var writeHereImage: UIImageView!
    
    //Outlets para o som
    @IBOutlet weak var backgroundRecord: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    //@IBOutlet weak var slowBtn: UIButton!
    @IBOutlet weak var audioSlider: UISlider!
    //@IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var checkAudio: UIImageView!
    
    //Outlets para a foto
    @IBOutlet weak var addPicture: UIButton!
    @IBOutlet weak var removeImage: UIButton!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var checkImage: UIImageView!
    
    
    //Outlets para o vídeo
    @IBOutlet weak var addVideo: UIButton!
    @IBOutlet weak var removeVideo: UIButton!
    @IBOutlet weak var videoView: UIImageView!
    @IBOutlet weak var checkVideo: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        recordingSession = AVAudioSession.sharedInstance()
        
        //required init to recording
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
        
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
        self.scrollView.contentSize.height = 1000;
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
        
        locationManager.stopUpdatingLocation();
        //print("entrou no load MAnager")
        let userLocation:CLLocationCoordinate2D = locations.last!.coordinate
        self.location = manager.location!
        
        self.latitude = String(userLocation.latitude);
        self.longitude = String(userLocation.longitude);
        
        print("locations = \(self.latitude) \(self.longitude)")
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(manager.location!) {
            (placemarks, error) -> Void in
            //if let placemarks = placemarks as? [CLPlacemark] where placemarks.count > 0 {
            //var placemark = placemarks[0]
            
            if let validPlacemark = placemarks?[0]{
                let placemark = validPlacemark as CLPlacemark;
                //self.location = String(placemark?.name)
                //print(location)
//                print("placemark")
//                print(String(placemark.name))
                self.address = String(placemark.name!)
                
                // Street addres
                //print("street")
                //print(placemark)
                //self.street = st
                //print("self.street")
                //print(self.street)
            }
        }
        
        
    }
    
    func loadRecordingUI(){
        
        // Custom the visual identity of audio player's background
        backgroundRecord.layer.borderWidth = 1
        backgroundRecord.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        backgroundRecord.layer.cornerRadius = 15
        backgroundRecord.layer.masksToBounds = true
        
        //LongPress para a criação de post
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(PostViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.2
        recordButton.addGestureRecognizer(longPressRecogniser)
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
            checkOn(checkTextPost)
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
    
    func checkOn(imageCheck : UIImageView) {
        let checkOn = UIImage(named: "check_on.png");
        imageCheck.image = checkOn
        print("passou aqui", imageCheck.image)
        
    }
    
    func handleLongPress(gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state == .Began {
            print("iniciar a gravação")
            recording()
            recordButton.enabled = false
        }
        
        if gestureRecognizer.state == .Ended {
            print("parar a gravação")
            
            audioRecorder.stop()
            AVAudioSession.sharedInstance()

            recordButton.enabled = true
            playButton.enabled = false
            
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func removeImage(sender: AnyObject) {
        
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
        photoImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        // save image in directory
        let imgUtils:ImageUtils = ImageUtils()
        self.imagePath = imgUtils.fileInDocumentsDirectory(self.generateIndexName("post_image", ext: "png"))
        imgUtils.saveImage(photoImage.image!, path: self.imagePath);
        
        self.image = photoImage.image!
        
        addPicture.hidden = true
        removeImage.hidden = false
        
        //set image as checked
        checkOn(checkImage)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        print("picker cancel.")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    //MARK: Audio Actions
    
    @IBAction func playAudio(sender: UIButton) {
        audioPlayer.prepareToPlay()
        audioPlayer.enableRate = false
        audioPlayer.stop()
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
    }
    
    @IBAction func changeAudioTime(sender: UISlider) {
        audioPlayer.stop()
        audioPlayer.currentTime = NSTimeInterval(audioSlider.value)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
    }
    
    func updateSlider() {
        audioSlider.value = Float(audioPlayer.currentTime)
    }
    
    
    //MARK: Post Actions
    
    @IBAction func savePost(sender: AnyObject) {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userId:Int = prefs.integerForKey("id") as Int
        print("enviando esse post...")
        print(self.latitude)
        print(self.longitude)
        print(self.address)
        print(self.category)
        print(self.imagePath)
        print(self.audioPath)
        print(self.textPostView.text)
        print(userId)
        
//        tagsView.resolveHashTags()
        let params : [String: String] = [
            "text" : textPostView.text,
            "audio" : self.audioPath,
            "location" : self.address,
            "latitude" : String(self.latitude),
            "longitude" : String(self.longitude),
            "category" : String(self.category),
            "photo" : self.imagePath,
            "user": String(userId)
        ]
        
        // example image data
        let image = self.image
        let imageData = UIImagePNGRepresentation(image)
        
        
        self.indicator.showActivityIndicator(self.view)
        
        // CREATE AND SEND REQUEST ----------
        
        let urlRequest = UrlRequestUtils.instance.urlRequestWithComponents(EndpointUtils.POST, parameters: params, imageData: imageData!)
        
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("go_to_confirm", sender: self)
                    }
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                    //New Alert Ccontroller
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
    
    @IBAction func cancelPost(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        stopBtn.hidden = false
        audioPlayer.prepareToPlay()
        audioPlayer.enableRate = true
        audioPlayer.stop()
        audioPlayer.rate = 0.5
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
    }
    
    func stopAudio(sender: UIButton) {
        audioPlayer.stop()
    }
    
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
    }

    
    func recording() {
       do {
            print("recording")
        
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000.0,
                AVNumberOfChannelsKey: 1 as NSNumber,
                AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
            ]
        
            let audioURL = self.getAudioURL()
        
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            
        } catch {
            finishRecording(success: false)
        }
    }
        
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
        
    func getAudioURL() -> NSURL {
        let recordingName = self.generateIndexName("audio", ext: "m4a")
        let audioFilename = getDocumentsDirectory().stringByAppendingString(recordingName)
        
        return NSURL(fileURLWithPath: audioFilename)
    }
    
    func generateIndexName(text:String, ext:String) ->String {
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        return text + "_" + formatter.stringFromDate(currentDateTime) + "." + ext
    }
        
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder,
        successfully flag: Bool) {
            if(flag) {
                do {
                playButton.enabled = true
                audioSlider.enabled = true
                
                recordedAudio = RecordedAudio()
                recordedAudio.filePathUrl = recorder.url
                recordedAudio.title = recorder.url.lastPathComponent
                
                try audioPlayer = AVAudioPlayer(contentsOfURL: recorder.url, fileTypeHint: nil)
                    audioPath = recorder.url.description
                    audioSlider.maximumValue = Float(audioPlayer.duration)
                
                    NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(PostViewController.updateSlider), userInfo: nil, repeats: true)
                    //println(points)
                    points += 10
                    //println(" depois points")
                
                    //set audio as checked
                    self.checkOn(checkAudio)
                    
                } catch {
                    fatalError("Failure to ...: \(error)")
                }
            } else {
                finishRecording(success: false)
                print("Ocorreu algum erro na gravação ")
                //recordButton.enabled = true
            }
    }
    
    func checkTagRewards(tag: String ){
        
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
                        self.checkOn(checkTextPost)
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
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set navigation bar background colour
        self.navigationController!.navigationBar.barTintColor = UIColor(hex: 0x3399CC)
        
        // Set navigation bar title text colour
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        recordButton.enabled = true
        playButton.enabled = false
        audioSlider.enabled = false
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showRewards" {
            let rewardController:RewardViewController = segue.destinationViewController as! RewardViewController
            points += tags.count * 5
            rewardController.points = points
        }
    }
}