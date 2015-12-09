//
//  PostViewController.swift
//  mplango
//
//  Created by Bruno Santos Ferreira on 16/08/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class PostViewController: UIViewController, AVAudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate  {
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    //MARK: Properties
    
    var post: Annotation? = nil
    var audioPlayer: AVAudioPlayer!
    var recordedAudio:RecordedAudio!
    var audioRecorder:AVAudioRecorder!
    var filePath: String!
    var tags = [String]()
    var points = 0
    
    //@IBOutlet weak var locationLabel: UILabel! (tirei o label, acho que não é necessário nesta tela)
    
    @IBOutlet weak var continueBtn: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    //Outlets para os tags e o texto
    
    @IBOutlet weak var tagsView: UITextView!
    @IBOutlet weak var textPostView: UITextView!
    @IBOutlet weak var maxLenghtLabel: UILabel!
    
    @IBOutlet weak var checkTags: UIImageView!
    @IBOutlet weak var checkTextPost: UIImageView!
    
    
    //Outlets para o som

    @IBOutlet weak var backgroundRecord: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var slowBtn: UIButton!
    
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var checkAudio: UIImageView!
    
    
    //Outlets para a foto
    
    @IBOutlet weak var addPicture: UIButton!
    @IBOutlet weak var removeImage: UIButton!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var checkImage: UIImageView!
    
    
    //Outlets para o vídeo
    
    
    @IBOutlet weak var checkVideo: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize.height = 300
        
        removeImage.hidden = true
        
        tagsView.delegate = self
        
        //confirmButton.hidden = true
        continueBtn.enabled = false

        tagsView.editable = true
        
        // Custom the visual identity of Image View
        
        photoImage.layer.cornerRadius = 10
        photoImage.layer.masksToBounds = true
        
        // Custom the visual identity of audio player's background
        
        backgroundRecord.layer.borderWidth = 1
        backgroundRecord.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        backgroundRecord.layer.cornerRadius = 15
        backgroundRecord.layer.masksToBounds = true
        
        
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressRecogniser.minimumPressDuration = 0.2
        recordButton.addGestureRecognizer(longPressRecogniser)
        
        if post != nil {
            print("post controller")
            print(post)
            //locationLabel.text = post?.locationName
        }
        
        //let aSelector : Selector = "touchOutsideTextField"
        //let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        //tapGesture.numberOfTapsRequired = 1
        //view.addGestureRecognizer(tapGesture)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        //Para determinar um número máximo de caracteres nos textfields
        let limitLength = 149
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        
        //label para contar os caracteres
        
        if(newLength>139)
        {
            maxLenghtLabel.textColor = UIColor.redColor()
        }
        maxLenghtLabel.text = String(newLength)
        
        return newLength <= limitLength

        
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
    
    
    
    //MARK: Image Actions
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func selectImageFromPhotoLibrary(sender: UIButton) {
        //Hide the keyboard
        tagsView.resignFirstResponder()
        textPostView.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library
        let imagePickerController = UIImagePickerController ()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .PhotoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func removeImage(sender: AnyObject) {
        
        photoImage.image = nil
        addPicture.hidden = false
        addPicture.enabled = true
        removeImage.hidden = true
        
    }
    
    
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        //Dismiss the picker if the user canceled
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //Set photoImageView to display the selected image
        photoImage.image = selectedImage
        
        //Dismiss the picker
        dismissViewControllerAnimated(true, completion: nil)
        
        addPicture.hidden = true
        removeImage.hidden = false
        removeImage.enabled = true
        
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
    
    @IBAction func savePost(sender: UIButton) {
        do {
            try moContext!.save()
        } catch {
            fatalError("Failure to save POST: \(error)")
        }
    }
    @IBAction func addPost(sender: UIButton) {
        print("action addPost tapped")
        prepareForInsertPost()
        confirmButton.hidden = false
        tagsView.resolveHashTags()
    }
    
    @IBAction func cancelPost(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("goto_map", sender: self)
    }
    
    func prepareForInsertPost () {
        print("post")
        //println(post)
        if post != nil {
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let email: String = prefs.objectForKey("USEREMAIL") as! String
            let fetchRequest = NSFetchRequest(entityName: "User")
            fetchRequest.predicate = NSPredicate(format: "email == %@", email)
            do {
                
                if let fetchResults = try moContext?.executeFetchRequest(fetchRequest) as? [User] {
                    let entityDescription = NSEntityDescription.entityForName("Post", inManagedObjectContext: moContext!)
                    let postEntity = Post(entity: entityDescription!, insertIntoManagedObjectContext: moContext)
                    postEntity.text     = tagsView.text
                    postEntity.audio    = filePath
                    postEntity.locationName = post!.locationName
                    postEntity.latitude  = Double(post!.coordinate.latitude)
                    postEntity.longitude = Double(post!.coordinate.longitude)
                    postEntity.category  = post!.category
                    postEntity.user = fetchResults[0]
                    print("user entity********************")
                    print(fetchResults)
                }
            } catch {
                fatalError("Failure to prepare POST: \(error)")
            }
        }
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
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let  char = text.cStringUsingEncoding(NSUTF8StringEncoding)!
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -60) {
            resolveHashTags();
        }
        return true
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