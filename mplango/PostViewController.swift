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
    
    var post: Annotation? = nil
    var audioPlayer: AVAudioPlayer!
    var recordedAudio:RecordedAudio!
    var audioRecorder:AVAudioRecorder!
    var filePath: String!
    var tags = [String]()
    var points = 0
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var textTextView: UITextView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textTextView.delegate = self
        
        confirmButton.hidden = true
        textTextView.editable = true
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressRecogniser.minimumPressDuration = 0.2
        recordButton.addGestureRecognizer(longPressRecogniser)
        
        if post != nil {
            print("post controller")
            print(post)
            locationLabel.text = post?.locationName
        }
        
        //let aSelector : Selector = "touchOutsideTextField"
        //let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        //tapGesture.numberOfTapsRequired = 1
        //view.addGestureRecognizer(tapGesture)
    }
    
    func touchOutsideTextField(){
        NSLog("touchOutsideTextField")
        self.view.endEditing(true)
        textTextView.resolveHashTags();
        
    }
    
    func handleLongPress(getstureRecognizer : UIGestureRecognizer){
        if getstureRecognizer.state == .Began {
            print("iniciar a gravação")
            recording()
            recordButton.enabled = false
        }
        
        if getstureRecognizer.state == .Ended {
            print("parar a gravação")
            
            audioRecorder.stop()
            _ = AVAudioSession.sharedInstance()
            //audioSession.setActive(false)
            
            recordButton.enabled = true
            playButton.enabled = false
            
        }
    }
    
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController ()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .PhotoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        //Dismiss the picker if the user canceled
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
      
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = image
        
        //Set photoImageView to display the selected image
        photoImageView.image = selectedImage
        
        //Dismiss the picker
        dismissViewControllerAnimated(true, completion: nil)
        
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
        textTextView.resolveHashTags()
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
                    postEntity.text     = textTextView.text
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
    
    //    @IBAction func playSlowAudio(sender: UIButton) {
    //        stopButton.hidden = false
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
        let nsText:NSString = textTextView.text
        
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
        
        
        textTextView.attributedText = attrString
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