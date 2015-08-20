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

class PostViewController: UIViewController, AVAudioRecorderDelegate {

    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var post: Annotation? = nil
    var audioPlayer: AVAudioPlayer!
    var recordedAudio:RecordedAudio!
    var audioRecorder:AVAudioRecorder!
    var filePath: String!
    
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var textTextField: UITextField!
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var slowButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressRecogniser.minimumPressDuration = 0.2
        recordButton.addGestureRecognizer(longPressRecogniser)
        if post != nil {
            println("post controller")
            println(post)
            locationLabel.text = post?.locationName
        }
    }
    
    func handleLongPress(getstureRecognizer : UIGestureRecognizer){
        if getstureRecognizer.state == .Began {
            println("iniciar a gravação")
            recording()
            recordButton.enabled = false
            recordingInProgress.hidden = false
            
        }
        
        if getstureRecognizer.state == .Ended {
            println("parar a gravação")
            
            audioRecorder.stop()
            var audioSession = AVAudioSession.sharedInstance()
            audioSession.setActive(false, error: nil)
            
            recordButton.enabled = true
            recordingInProgress.hidden = true
            
            playButton.hidden = false
            slowButton.hidden = false
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set navigation bar background colour
        self.navigationController!.navigationBar.barTintColor = UIColor(hex: 0x3399CC)
        
        // Set navigation bar title text colour
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        recordingInProgress.hidden = true
        recordButton.enabled = true
        playButton.hidden = true
        slowButton.hidden = true
        stopButton.hidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playAudio(sender: UIButton) {
            stopButton.hidden = false
            audioPlayer.prepareToPlay()
            audioPlayer.enableRate = false
            audioPlayer.stop()
            audioPlayer.currentTime = 0.0
            audioPlayer.play()
    }
    
    @IBAction func addPost(sender: UIButton) {
        println("action addPost tapped")
        prepareForInsertPost()
    }
    
    func prepareForInsertPost () {
        println("post")
        //println(post)
        if post != nil {
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let email: String = prefs.objectForKey("USEREMAIL") as! String
            let fetchRequest = NSFetchRequest(entityName: "User")
            fetchRequest.predicate = NSPredicate(format: "email == %@", email)
            
            if let fetchResults = moContext?.executeFetchRequest(fetchRequest, error: nil) as? [User] {
                
                let user: User = fetchResults[0];
                let entityDescription = NSEntityDescription.entityForName("Post", inManagedObjectContext: moContext!)
                let postEntity = Post(entity: entityDescription!, insertIntoManagedObjectContext: moContext)
                postEntity.text     = textTextField.text
                postEntity.audio    = filePath
                postEntity.locationName = post!.locationName
                postEntity.latitude  = Double(post!.coordinate.latitude)
                postEntity.longitude = Double(post!.coordinate.longitude)
                postEntity.category  = post!.category
                postEntity.user = fetchResults[0]
                println("user entity********************")
                println(fetchResults)
                moContext?.save(nil)
                
            }
        }
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        stopButton.hidden = false
        audioPlayer.prepareToPlay()
        audioPlayer.enableRate = true
        audioPlayer.stop()
        audioPlayer.rate = 0.5
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        audioPlayer.prepareToPlay()
        audioPlayer.stop()
        stopButton.hidden = true
    }
    
    func recording() {
        println("recording")
        recordingInProgress.hidden = false
        stopButton.hidden = false
        recordButton.enabled = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        // Modify the line that sets the name of the recording
        //let recordingName = "record_audio.wav"
        
        let pathArray = [dirPath, recordingName]
        
        let path = NSURL.fileURLWithPathComponents(pathArray)
        //filePath = path?.fileURL.description
        //var filePathUrl = NSURL.fileURLWithPath(filePath)
        
        
        //if let filePath = NSBundle.mainBundle().pathForResource("record_audio", ofType: "wav") {
        //var filePathUrl = NSURL.fileURLWithPath(filePath)
        //audioPlayer = AVAudioPlayer(contentsOfURL: filePathUrl, error: nil)
        //} else {
            //println("O endereço está vazio")
        //}
        
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        audioRecorder = AVAudioRecorder(URL: path, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder,
        successfully flag: Bool) {
            if(flag) {
                recordedAudio = RecordedAudio()
                recordedAudio.filePathUrl = recorder.url
                recordedAudio.title = recorder.url.lastPathComponent
                
                audioPlayer = AVAudioPlayer(contentsOfURL: recorder.url, error: nil)
                filePath = recorder.url.description
                println("audioPlayer.url")
                println(audioPlayer.url.description)
                
            } else {
                println("Ocorreu algum erro na gravação ")
                //recordButton.enabled = true
                //stopButton.enabled = true
            }
    }
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
}