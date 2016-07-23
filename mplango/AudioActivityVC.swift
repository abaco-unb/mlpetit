//
//  AudioActivityVC.swift
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

class AudioActivityVC: UIViewController, AVAudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    //MARK: Properties
    
    var activity: Test? = nil
    
    var audioPlayer: AVAudioPlayer!
    var recordedAudio:RecordedAudio!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var audioPath: String = ""
    var imagePath: String = ""
    
    var image:UIImage!
    
    @IBOutlet weak var sentBtn: UIBarButtonItem!
    //    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    //Outlets para o texto
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var maxLenghtLabel: UILabel!
    @IBOutlet weak var writeHereImage: UIImageView!
    
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
    
    //Outlets para a foto
    @IBOutlet weak var addPicture: UIButton!
    @IBOutlet weak var removeImage: UIButton!
    @IBOutlet weak var photoImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
        
        recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if allowed {
                    self.loadRecordingUI()
                } else {
                    NSLog("Error: viewDidLoad -> microfone indisponível")
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        
                        //New Alert Ccontroller
                        let alertController = UIAlertController(title: "Ops!", message: "Favor conceda permissão de acesso do app ao seu microfone!", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The user not is okay.")
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        
        //required init to recording
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch _ {
            NSLog("Error: viewDidLoad -> set Category failed")
        }
        do {
            try recordingSession.setActive(true)
        } catch _ {
            NSLog("Error: viewDidLoad -> set Active failed")
        }
        do {
            try recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        } catch _ {
            NSLog("Error: viewDidLoad -> set override output Audio port     failed")
        }
        
        //        self.view.addSubview(scrollView)
        //        scrollView.addSubview(contentView)
        
        //tagsView.delegate = self
        textView.delegate = self
        
        sentBtn.enabled = false
        //        removeImage.hidden = true
        
        // esconder os botões do áudio para não confundir o usuário e deixar visível apenas o botão para gravar
        //        playButton.hidden = true
        //        stopBtn.hidden = true
        //        audioSlider.hidden = true
        
        // Custom the visual identity of Image View
        //        photoImage.layer.cornerRadius = 10
        //        photoImage.layer.masksToBounds = true
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AudioActivityVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    //    override func viewWillLayoutSubviews()
    //    {
    //        super.viewWillLayoutSubviews();
    //        self.scrollView.contentSize.height = 800;
    //    }
    
    
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
            textView.resignFirstResponder()
            return false
        }
        
        let limitLength = 149
        
        let text : String = textView.text
        
        let newLength = text.characters.count - range.length
        //        maxLenghtLabel.textColor = UIColor.darkGrayColor()
        //        maxLenghtLabel.text = String(newLength)
        
        //        if (newLength > 139 && newLength <= 149) {
        //            maxLenghtLabel.textColor = UIColor.redColor()
        //        }
        
        return newLength <= limitLength
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        writeHereImage.hidden = true
    }
    
    func touchOutsideTextField(){
        NSLog("touchOutsideTextField")
        self.view.endEditing(true)
        textView.resolveHashTags();
        
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
        //Hide the keyboard
        
        textView.resignFirstResponder()
        
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
    
    func openCamera()
    {
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
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        print("picker cancel.")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: Audio Process
    
    @IBAction func playAudio(sender: UIButton) {
        playButton.hidden = true
        stopBtn.hidden = false
        audioPlayer.prepareToPlay()
        audioPlayer.enableRate = false
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
        
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        playButton.hidden = false
        stopBtn.hidden = true
        audioPlayer.pause()
    }
    
    @IBAction func changeAudioTime(sender: UISlider) {
        audioPlayer.stop()
        audioPlayer.currentTime = NSTimeInterval(audioSlider.value)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
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
            playButton.enabled = true
            playButton.hidden = false
            audioSlider.enabled = true
            audioSlider.hidden = false
            
        }
    }
    
    func updateSlider() {
        audioSlider.value = Float(audioPlayer.currentTime)
    }
    
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
    }
    
    func recording() {
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        let audioURL = self.getAudioURL()
        
        print(audioURL)
        
        do {
            print("recording")
            labelRecording.text = "En train d'enregistrer..."
            labelRecording.textColor = UIColor(hex: 0xF95253)
            self.blinkComponent(self.labelRecording)
            iconAudio.image = UIImage(named: "icon_audio_red")
            self.blinkComponent(self.iconAudio)
            
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
        } catch {
            NSLog("Error: func recording")
            finishRecording(success: false)
        }
    }
    
    func loadRecordingUI(){
        
        // Custom the visual identity of audio player's background
        backgroundRecord.layer.borderWidth = 1
        backgroundRecord.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        backgroundRecord.layer.cornerRadius = 15
        backgroundRecord.layer.masksToBounds = true
        
        //LongPress para a criação de post
//        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(PostViewController.handleLongPress(_:)))
//        longPressRecogniser.minimumPressDuration = 0.2
//        recordButton.addGestureRecognizer(longPressRecogniser)
    }
    
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getAudioURL() -> NSURL {
        let recordingName = self.generateIndexName("audio", ext: "m4a")
        let audioFilename = getDocumentsDirectory().stringByAppendingString("/").stringByAppendingString(recordingName)
        
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
                print(" play fx")
                let alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beep-recorded", ofType: "wav")!)
                try audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, fileTypeHint: nil)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
            }catch _ {
                NSLog("Error: play effect ")
            }
            
            do {
                print(" audioRecorderDidFinishRecording")
                playButton.enabled = true
                
                audioSlider.hidden = false
                audioSlider.enabled = true
                
                labelRecording.text = "Audio ajouté."
                labelRecording.textColor = UIColor(hex: 0x2C98D4)
                
                iconAudio.image = UIImage(named: "icon_audio")
                iconAudio.layer.removeAllAnimations()
                labelRecording.layer.removeAllAnimations()
                
                print(1)
                recordedAudio = RecordedAudio()
                recordedAudio.filePathUrl = recorder.url
                recordedAudio.title = recorder.url.lastPathComponent
                print(2)
                print(recorder.url.description)
                
                try audioPlayer = AVAudioPlayer(contentsOfURL: recorder.url, fileTypeHint: nil)
                audioPath = recorder.url.description
                audioSlider.maximumValue = Float(audioPlayer.duration)
                
                NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(AudioActivityVC.updateSlider), userInfo: nil, repeats: true)
                
                
            } catch {
                fatalError("Failure to ...: \(error)")
            }
        } else {
            NSLog("Error: func audioRecorderDidFinishRecording")
            finishRecording(success: false)
            //recordButton.enabled = true
        }
    }
    
    func blinkComponent(comp: UIView) {
        comp.alpha = 0;
        UIView.animateWithDuration(0.7, delay: 0.0, options: [.Repeat, .Autoreverse, .CurveEaseInOut], animations:
            {
                comp.alpha = 1
            }, completion: nil)
    }
    
    
    //MARK: Post Actions
    
    @IBAction func send(sender: AnyObject) {
        
        //        self.sendActivity()
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set navigation bar background colour
        self.navigationController!.navigationBar.barTintColor = UIColor(hex: 0x3399CC)
        
        // Set navigation bar title text colour
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        //        recordButton.enabled = true
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //        if segue.identifier == "showRewards" {
        //            let rewardController:RewardViewController = segue.destinationViewController as! RewardViewController
        //            points += tags.count * 5
        //            rewardController.points = points
        //        }
    }
    
    
}