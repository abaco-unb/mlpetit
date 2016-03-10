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
    var audioRecorder:AVAudioRecorder!
    var filePath: String!
    var tags = [String]()
    var points = 0
    var category = 0
    var longitude: Double? = nil
    var latitude: Double? = nil
    
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
        
        if (CLLocationManager.locationServicesEnabled())
        {
            let locationManager = CLLocationManager()
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        print("categoria")
        print(self.category)
        
        scrollView.contentSize.height = 300
        
        tagsView.delegate = self
        textPostView.delegate = self
        
        //confirmButton.hidden = true
        continueBtn.enabled = false
        removeImage.hidden = true
        tagsView.editable = true
        
        // Custom the visual identity of Image View
        photoImage.layer.cornerRadius = 10
        photoImage.layer.masksToBounds = true
        
        // Custom the visual identity of audio player's background
        backgroundRecord.layer.borderWidth = 1
        backgroundRecord.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        backgroundRecord.layer.cornerRadius = 15
        backgroundRecord.layer.masksToBounds = true
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        
        //LongPress para a criação de post
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressRecogniser.minimumPressDuration = 0.2
        recordButton.addGestureRecognizer(longPressRecogniser)
        
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        let location = locations.last! as CLLocation
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let limitLength = 149
        guard let text = textPostView.text else { return true }
        let newLength = text.characters.count - range.length
        
        maxLenghtLabel.text = String(newLength)
        
        if (newLength > 139)
        {
            maxLenghtLabel.textColor = UIColor.redColor()
        }
        
        else if (newLength < 140)
        {
            maxLenghtLabel.textColor = UIColor.darkGrayColor()
        }
        
        //estas linhas foram copiadas do código mais abaixo que chamava a mesma função. Do que eu entendi é para os tags. Copiei tudo menos o "return true", pois aqui já tem um return
        let char = text.cStringUsingEncoding(NSUTF8StringEncoding)!
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -60) {
            resolveHashTags();
        }
        
        return newLength <= limitLength
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        writeHereImage.hidden = true
    }
    
    func touchOutsideTextField(){
        NSLog("touchOutsideTextField")
        self.view.endEditing(true)
        tagsView.resolveHashTags();
        
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
            _ = AVAudioSession.sharedInstance()
            //audioSession.setActive(false)
            
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
        
        tagsView.resolveHashTags()
        
        let params : [String: AnyObject] = [
            "text" : tagsView.text,
            "audio" : filePath,
            "location" : "",
            "latitude" : String(self.latitude),
            "longitude" : String(self.longitude),
            "category" : String(self.category),
            "photo" : "../",//self.imgPath,
            "user": userId
        ]
        
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
        self.performSegueWithIdentifier("goto_map", sender: self)
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
    
    func recording() {
       do {
        print("recording")
        //recordingInProgress.hidden = false
        recordButton.enabled = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        // Modify the line that sets the name of the recording
        //let recordingName = "record_audio.wav"
        
        let pathArray = [dirPath, recordingName]
        _ = NSURL.fileURLWithPathComponents(pathArray)
        
        //filePath = path?.fileURL.description
        //var filePathUrl = NSURL.fileURLWithPath(filePath)
        
        
        //if let filePath = NSBundle.mainBundle().pathForResource("record_audio", ofType: "wav") {
        //var filePathUrl = NSURL.fileURLWithPath(filePath)
        //audioPlayer = AVAudioPlayer(contentsOfURL: filePathUrl, error: nil)
        //} else {
        //println("O endereço está vazio")
        //}
        
        
            let session = AVAudioSession.sharedInstance
            try session().setCategory(AVAudioSessionCategoryPlayAndRecord)
            //audioRecorder = AVAudioRecorder(URL: path!, settings: [nil])
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } catch {
            fatalError("Failure to ...: \(error)")
        }
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
                
                _ =  NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateSlider"), userInfo: nil, repeats: true)
                //println(points)
                points += 10
                //println(" depois points")
                } catch {
                    fatalError("Failure to ...: \(error)")
                }
            } else {
                print("Ocorreu algum erro na gravação ")
                //recordButton.enabled = true
            }
    }
    
    /* 
    JA USADO ACIMA PARA O LIMITE DE CARACTERES. COPIEI TUDO ALI MENOS O RETURN TRUE
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let  char = text.cStringUsingEncoding(NSUTF8StringEncoding)!
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -60) {
            resolveHashTags();
        }
        return true
    }
    */
    
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