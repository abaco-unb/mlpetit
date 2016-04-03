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
    
    var item: Carnet? = nil
    
    var audioPlayer: AVAudioPlayer!
    var recordedAudio:RecordedAudio!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var filePath: String!
    
    var restPath = "http://server.maplango.com.br/note-rest"
    var indicator:ActivityIndicator = ActivityIndicator()
    
    @IBOutlet weak var saveWordButton: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //Outlets para o texto
    @IBOutlet var wordTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var maxLenghtLabel: UILabel!
    @IBOutlet weak var writeHereImage: UIImageView!
    
    //Outlets para o audio
    @IBOutlet weak var backgroundRecord: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var audioTimerLabel: UILabel!
    
    //Outlets para a foto
    @IBOutlet var photoImage: UIImageView!
    @IBOutlet weak var addPicture: UIButton!
    @IBOutlet weak var removeImage: UIButton!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize.height = 300

        removeImage.hidden = true
        
        // botões do audio recorder
        playButton.hidden = true
        audioTimerLabel.hidden = true
        stopBtn.hidden = true
        
        // Enable the Save button only if the text field has a valid Word name
        checkValidWordName()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CarnetAddVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(CarnetAddVC.handleLongPress(_:)))
        
        longPressRecogniser.minimumPressDuration = 1.0
        recordButton.addGestureRecognizer(longPressRecogniser)
        
        wordTextField.delegate = self
        descTextView.delegate = self
        
        if item != nil {
            wordTextField.text = item?.word
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
    
    func loadRecordingUI(){
        
        // Custom the visual identity of audio player's background
        backgroundRecord.layer.borderWidth = 1
        backgroundRecord.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        backgroundRecord.layer.cornerRadius = 15
        backgroundRecord.layer.masksToBounds = true
        
        //LongPress para a criação de post
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(CarnetAddVC.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.2
        recordButton.addGestureRecognizer(longPressRecogniser)
    }

    
    
    

    //MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
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
        photoImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        addPicture.hidden = true
        removeImage.hidden = false
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        print("picker cancel.")
        dismissViewControllerAnimated(true, completion: nil)
    }


    // MARK: Audio Process
    
    @IBAction func playAudio(sender: UIButton) {
        audioPlayer.prepareToPlay()
        audioPlayer.enableRate = false
        audioPlayer.stop()
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
        //audioTimerLabel.hidden = false
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
    
//    @IBAction func playSlowAudio(sender: UIButton) {
//        stopBtn.hidden = false
//        audioPlayer.prepareToPlay()
//        audioPlayer.enableRate = true
//        audioPlayer.stop()
//        audioPlayer.rate = 0.5
//        audioPlayer.currentTime = 0.0
//        audioPlayer.play()
//    }
    
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
                    
                    NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(CarnetAddVC.updateSlider), userInfo: nil, repeats: true)
                    
                } catch {
                    fatalError("Failure to ...: \(error)")
                }
            } else {
                finishRecording(success: false)
                print("Ocorreu algum erro na gravação ")
                //recordButton.enabled = true
            }
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

   
    
    // MARK: Item Carnet Process
    
    
    @IBAction func saveWordButton(sender: AnyObject) {
        createItemCarnet()
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    func createItemCarnet() {
        ////recupera o id da sessão
//        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//        let id: Int = prefs.objectForKey("id") as! Int
        
        self.indicator.showActivityIndicator(self.view)
        let params : [String: AnyObject] = [
            "word" : "",
            "desc" : "",
            "photo" : ""
        ]
        Alamofire.request(.POST, self.restPath, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("...", sender: self.saveWordButton)
                    }
                }
            })
    }
    
    
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveWordButton.enabled = false
    }
 
    func checkValidWordName() {
        // Disable the Save button if the text field is empty.
        let text = wordTextField.text ?? ""
        saveWordButton.enabled = !text.isEmpty
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidWordName()
        navigationItem.title = wordTextField.text
    }
    

    // MARK: - Navigation

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if saveWordButton === sender {
            let word = wordTextField.text ?? ""
            let desc = descTextView.text ?? ""
            let photo = photoImage.image
          
            //falta som
        }
    }
}
