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
import CoreLocation



class PostViewController: UIViewController, AVAudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIAlertViewDelegate, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate {
    
    //MARK: Properties
    var post: Annotation? = nil
    
    var audioPlayer: AVAudioPlayer!
    var recordedAudio:RecordedAudio!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var locationManager = CLLocationManager()
    var location:CLLocation!
    var address:String = ""
    var latitude:String = ""
    var longitude:String = ""
    
    var filePath: String!
    var tags = [String]()
    var points = 0
    var category = 0
    
    var restPath = "http://server.maplango.com.br/post-rest"
    var indicator:ActivityIndicator = ActivityIndicator()
   
    @IBOutlet weak var continueBtn: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //Outlets para os tags e o texto
    @IBOutlet weak var tagsView: UITextView!
    @IBOutlet weak var textPostView: UITextView!
    @IBOutlet weak var maxLenghtLabel: UILabel!
    @IBOutlet weak var checkTags: UIImageView!
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
        
        //ui configurations
        scrollView.contentSize.height = 300
        
        tagsView.delegate = self
        textPostView.delegate = self
        
        //confirmButton.hidden = true
        continueBtn.enabled = true
        removeImage.hidden = true
        tagsView.editable = true
        
        // Custom the visual identity of Image View
        photoImage.layer.cornerRadius = 10
        photoImage.layer.masksToBounds = true
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        
        //let aSelector : Selector = "touchOutsideTextField"
        //let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        //tapGesture.numberOfTapsRequired = 1
        //view.addGestureRecognizer(tapGesture)
        
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
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
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
        
        if (textView == tagsView) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -60) {
                resolveHashTags();
            }
            
            return true;
        }
        
        let text : String = textPostView.text
        
        let newLength = text.characters.count - range.length
        maxLenghtLabel.textColor = UIColor.darkGrayColor()
        maxLenghtLabel.text = String(newLength)
        
        if (newLength > 139 && newLength <= 149) {
            maxLenghtLabel.textColor = UIColor.redColor()
        }
        if(newLength == 10) {
            checkTextPost.tintColor = UIColor.greenColor()
        }
        
        return newLength <= limitLength
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView == tagsView) {
            tagsView.text = ""
        } else if(textView == textPostView) {
            writeHereImage.hidden = true
        }
    }
    
    func touchOutsideTextField(){
        NSLog("touchOutsideTextField")
        self.view.endEditing(true)
        tagsView.resolveHashTags();
        
    }
    
    func checkOn(imageCheck : UIImageView) {
        let checkOn = UIImage(named: "images/atividade_aprovada.png");
        imageCheck.image = checkOn
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
    
    
    // MARK : Image Picker Process
    
    var picker:UIImagePickerController? = UIImagePickerController()
    var popover:UIPopoverPresentationController? = nil
    
    @IBAction func removeImage(sender: AnyObject) {
        
        photoImage.image = nil
        addPicture.hidden = false
        addPicture.enabled = true
        removeImage.hidden = true
        
    }
    
    @IBAction func selectImageFromPhotoLibrary(sender: UIButton) {
        //Hide the keyboard
        
        tagsView.resignFirstResponder()
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
        addPicture.hidden = true
        removeImage.hidden = false
        
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
        //print(self.filePath)
        print(userId)
        
//        tagsView.resolveHashTags()
        let params : [String: AnyObject] = [
            "text" : tagsView.text,
            "audio" : " ",
            "location" : self.address,
            "latitude" : String(self.latitude),
            "longitude" : String(self.longitude),
            "category" : String(self.category),
            "photo" : "../",
            "user": userId
        ]

        self.indicator.showActivityIndicator(self.view)
        Alamofire.request(.POST, self.restPath, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("go_to_map", sender: self)
                    }
                }
            })
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
        
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".m4a"
        let audioFilename = getDocumentsDirectory().stringByAppendingString(recordingName)
        
        return NSURL(fileURLWithPath: audioFilename)
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
                filePath = recorder.url.description
                audioSlider.maximumValue = Float(audioPlayer.duration)
                
                NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateSlider"), userInfo: nil, repeats: true)
                //println(points)
                points += 10
                //println(" depois points")
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
        let nsText:NSString = tagsView.text
        
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
                    
                    
                    //set as checked
                    self.checkOn(checkTags)
                    
                } else {
                    if let _ = tags.indexOf(stringifiedWord) {
                        print("já adicionado")
                        
                    } else {
                        if stringifiedWord != "" {
                            tags.append(stringifiedWord)
                        }
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
        
        
        tagsView.attributedText = attrString
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