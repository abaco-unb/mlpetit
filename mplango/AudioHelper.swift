//
//  AudioHelper.swift
//  mplango
//
//  Created by Bruno on 12/07/16.
//  Copyright © 2016 unb.br. All rights reserved.
//

import UIKit
import AVFoundation

class AudioHelper: NSObject, AVAudioRecorderDelegate  {
    
    static let instance = AudioHelper()
    
    var audioPlayer: AVAudioPlayer!
    var recordedAudio:RecordedAudio!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var points: Int = 0
    
    var audioPath: String = ""
    
    
    var checkAudio: UILabel!
    var iconAudio: UIImageView!
    
    var labelRecording: UILabel!
    var labelDuration: UILabel!
    
    //Outlets para o som
    var backgroundRecord: UIView!
    
    var playButton: UIButton!
    var recordButton: UIButton!
    var stopBtn: UIButton!
    var audioSlider: UISlider!
    
    var tapper: UITapGestureRecognizer?
    
    var delegate : UIViewController!
    
    func _init(container: UIView, audioPath : String) {
        
        print("Init Player forever alone : ")
        self.initAudio()
        
        
        print("criando botão play")
        self.playButton = self.createButton("listen_btn.png", frame: CGRectMake(15, 10, 20, 20))
        playButton.addTarget(self, action: #selector(AudioHelper.play(_:)), forControlEvents: .TouchUpInside)
        container.addSubview(playButton)
        
        print("criando botão stop")
        self.stopBtn = self.createButton("stop_btn.png", frame: CGRectMake(15, 10, 20, 20))
        stopBtn.addTarget(self, action: #selector(AudioHelper.stop(_:)), forControlEvents: .TouchUpInside)
        stopBtn.hidden = true
        container.addSubview(stopBtn)
        
        print("criando slider")
        self.audioSlider = self.createSlider()
        container.addSubview(audioSlider)
        self.addConstraint(container, ui: audioSlider, xattr: NSLayoutAttribute.CenterX, xcons: 0, wcons: 200, hcons: 100)
        
        print(container.frame.height)
        print("criando label")
        self.labelDuration = createLabel(CGRectMake(container.frame.width - 50, 10, 50, 21))
        container.addSubview(labelDuration)
        
        self.prepareToListen(audioPath)
    }
    
    func _init(container: UIView, icon: UIImageView, check: UILabel, label: UILabel, btnRecorder: UIButton) {
        
        print("Init Player with record button ")
        
        self.iconAudio = icon
        self.checkAudio = check
        self.backgroundRecord = container
        self.labelRecording = label
        self.recordButton = btnRecorder
        
        print("criando botão play")
        self.playButton = self.createButton("listen_btn.png", frame: CGRectMake(15, 11, 23, 23))
        playButton.addTarget(self, action: #selector(AudioHelper.play(_:)), forControlEvents: .TouchUpInside)
        container.addSubview(playButton)
        
        print("criando botão stop")
        self.stopBtn = self.createButton("stop_btn.png", frame: CGRectMake(15, 11, 23, 23))
        stopBtn.addTarget(self, action: #selector(AudioHelper.stop(_:)), forControlEvents: .TouchUpInside)
        stopBtn.hidden = true
        container.addSubview(stopBtn)
        
        print("criando slider")
        self.audioSlider = self.createSlider()
        container.addSubview(audioSlider)
        self.addConstraint(container, ui: audioSlider, xattr: NSLayoutAttribute.CenterX, xcons: -4, wcons: 180, hcons: 100)
        
        initRecorder()
        
        
    }
    
    func _init(delegate: UIViewController, icon: UIImageView, check: UILabel, background: UIView, label: UILabel, btnStop: UIButton, btnPlay: UIButton, btnRecorder: UIButton) {
        print("Init 3 : ")
        self.delegate = delegate
        
        self.iconAudio = icon
        self.checkAudio = check
        self.backgroundRecord = background
        self.labelRecording = label
        self.playButton = btnPlay
        
        self.playButton.addTarget(self, action: #selector(AudioHelper.play), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.stopBtn = btnStop
        
        self.stopBtn.addTarget(self, action: #selector(AudioHelper.stop), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.recordButton = btnRecorder
        
        
        btnStop.hidden = true;
        btnPlay.hidden = false
        btnPlay.enabled = true;
        
        self.audioSlider = self.createSlider()
        self.addConstraint(background, ui: audioSlider, xattr: NSLayoutAttribute.CenterX, xcons: 0, wcons: 200, hcons: 100)
        
        background.addSubview(audioSlider)
        
        initRecorder()
        
    }
    
    func initRecorder() {
        self.recordingSession = AVAudioSession.sharedInstance()
        self.recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
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
                        self.delegate.presentViewController(alertController, animated: true, completion: nil)
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
    }
    
    func initAudio() -> Bool {
        var result = true
        
        //required init to play
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch _ {
            result = false
            NSLog("Error: viewDidLoad -> set Category failed")
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
            result = false
            NSLog("Error: viewDidLoad -> set Active failed")
        }
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        } catch _ {
            result = false
            NSLog("Error: viewDidLoad -> set override output Audio port     failed")
        }
        
        return result
    }
    
    func createLabel(frame : CGRect) -> UILabel {
        let label = UILabel(frame: frame)
        //label.center = CGPointMake(160, 284)
        label.textAlignment = NSTextAlignment.Center
        label.text = "2:00"
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.grayColor()
        return label
    }
    
    func createButton (imagee : String, frame : CGRect ) -> UIButton {
        
        let button = UIButton(frame: frame)
        let image = UIImage(named: imagee) as UIImage?
        button.setImage(image, forState: UIControlState.Normal)
        button.enabled = false
        button.userInteractionEnabled = true
        return button
    }
    
    func createSlider () -> UISlider {
        
        let audioSlider = UISlider()
        audioSlider.minimumValue = 0
        audioSlider.maximumValue = 100
        audioSlider.continuous = true
        audioSlider.value = 0
        audioSlider.setThumbImage(UIImage(named: "thumb_slider.png"), forState: UIControlState.Normal)
        audioSlider.addTarget(self, action: #selector(AudioHelper.sliderValueDidChange(_:)), forControlEvents: .ValueChanged)
        audioSlider.translatesAutoresizingMaskIntoConstraints = false
        return audioSlider
    }
    
    func addConstraint(view : UIView, ui : AnyObject, xattr: NSLayoutAttribute, xcons: CGFloat, wcons: CGFloat, hcons:CGFloat) {
        
        let horizontalConstraint = NSLayoutConstraint(item: ui, attribute: xattr, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: xattr, multiplier: 1, constant: xcons)
        view.addConstraint(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint(item: ui, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraint)
        
        let widthConstraint = NSLayoutConstraint(item: ui, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: wcons)
        view.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: ui, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: hcons)
        view.addConstraint(heightConstraint)
    }
    
    func sliderValueDidChange(sender:UISlider!)
    {
        print("value--\(sender.value)")
    }
    
    func prepareToListen(audio : String) {
        
        do {
            
            print(" inicializando o audio nesse endereço")
            print(audio)
            
            if let soundData = self.loadAudioFromPath(audio) {
                
                try self.audioPlayer = AVAudioPlayer(data: soundData, fileTypeHint: "m4a")
                
                    self.labelDuration.text = String(format: "%.2f", Double(audioPlayer.duration))
                    self.audioSlider.maximumValue = Float(audioPlayer.duration)
                    self.playButton.enabled = true
                
                    print("audioPlayer.duration.description")
                    print(self.audioPlayer.duration.description)
                
                    NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                
                    //self.play()
            }
            
        } catch {
            fatalError("Failure in method listen to ...: \(error)")
        }
        
    }
    
    
    func loadAudioFromPath(remotePath: String) -> NSData? {
        
        if let audio : NSData = NSCache.sharedInstance.objectForKey(remotePath) as? NSData {
            
            print("audio recuperado do cache : " + remotePath)
            return audio
            
        } else {
            
            if let url = NSURL(string: remotePath) {
                if let data = NSData(contentsOfURL: url) {
                    print("audio recuperado sem cache : " + remotePath)
                    NSCache.sharedInstance.setObject(data, forKey: remotePath)
                    return data
                }
            } else {
                print("audio não pode ser recuperado sem cache : " + remotePath)
            }
        }
        
        return nil
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
        
        self.points = 0;
        
        do {
            
            let alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beep-recorded", ofType: "wav")!)
            try audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, fileTypeHint: nil)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
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
            finishRecording()
        }
    }
    
    func loadRecordingUI(){
        
        // Custom the visual identity of audio player's background
        backgroundRecord.layer.borderWidth = 1
        backgroundRecord.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        backgroundRecord.layer.cornerRadius = 15
        backgroundRecord.layer.masksToBounds = true
        
        //LongPress para a criação de post
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.2
        recordButton.addGestureRecognizer(longPressRecogniser)
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
                
                NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                
                print(points)
                self.points += GamificationRules.AUDIO_TOTAL_POINTS
                print(" depois points")
                
                //set audio as checked
                //                    self.checkOn(checkAudio)
                
                self.checkAudio.textColor = UIColor(hex: 0x43A047)
                self.checkAudio.font = UIFont.boldSystemFontOfSize(15)
                
                
            } catch {
                fatalError("Failure to ...: \(error)")
            }
        } else {
            NSLog("Error: func audioRecorderDidFinishRecording")
            finishRecording()
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
    
    func stop(sender: UIButton!) {
        
        print("teste stop now")
        
        stopBtn.hidden = true
        
        playButton.hidden = false
        playButton.enabled = true
        
        audioPlayer.pause()
    }
    
    func play(sender: UIButton!) {
        print("teste play now")
        
        playButton.hidden = true
        stopBtn.hidden = false
        stopBtn.enabled = true
        
        audioPlayer.prepareToPlay()
        
        //audioPlayer.enableRate = false
//        audioPlayer.stop()
        audioPlayer.play()
        
        
        print("depois do play")
    }
    
    func changeAudioTime() {
        audioPlayer.stop()
        audioPlayer.currentTime = NSTimeInterval(audioSlider.value)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
    }
    
    func updateSlider() {
        self.audioSlider.value = Float(self.audioPlayer.currentTime)
    }
    
    func finishRecording() {
        audioRecorder.stop()
        audioRecorder = nil
    }
    
}