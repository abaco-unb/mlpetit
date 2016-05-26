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
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var audioSlider: UISlider!
    
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
        
//        if item != nil {
//            wordTextField.text = item.word
//        }
        
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

    func generateIndexName(text:String, ext:String) ->String {
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        return text + "_" + formatter.stringFromDate(currentDateTime) + "." + ext
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
                    audioPath = recorder.url.description
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
        
        if self.image != nil {
            self.saveNote(self.image, params: params)
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
    
    func saveNote(image: UIImage, params: Dictionary<String, String>) {
        // example image data
        let imageData = image.lowestQualityJPEGNSData
        
        // save image in directory
        let imgUtils:ImageUtils = ImageUtils()
        self.imagePath = imgUtils.fileInDocumentsDirectory(self.generateIndexName("note_image", ext: "png"))
        ImageUtils.instance.saveImage(self.photoImage.image!, path: self.imagePath);
        
        self.indicator.showActivityIndicator(self.view)
        
        // CREATE AND SEND REQUEST ----------
        let urlRequest = UrlRequestUtils.instance.urlRequestWithComponents(EndpointUtils.CARNET, parameters: params, imageData: imageData)
        
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
    

    // MARK: - Navigation
//    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if(segue.identifier == "go_to_carnet"){
            let tabVC = segue.destinationViewController as! UITabBarController
            tabVC.selectedIndex = 3
        }
    }
}
