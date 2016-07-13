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
    
    //Outlets para o som
    var backgroundRecord: UIView!
    
    var playButton: UIButton!
    var recordButton: UIButton!
    var stopBtn: UIButton!
    var audioSlider: UISlider!
    
    var delegate : UIViewController!
    
    func _init(delegate: UIViewController, icon: UIImageView, check: UILabel, background: UIView, label: UILabel, btnStop: UIButton, btnPlay: UIButton, btnRecorder: UIButton, slider: UISlider) {
    
        self.delegate = delegate
        
        self.iconAudio = icon
        self.checkAudio = check
        self.backgroundRecord = background
        self.labelRecording = label
        self.playButton = btnPlay
        self.stopBtn = btnStop
        self.recordButton = btnRecorder
        self.audioSlider = slider
        
        
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
                
                NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                
                print(points)
                self.points += 10
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
    
    func stop() {
        playButton.hidden = false
        stopBtn.hidden = true
        audioPlayer.stop()
    }
    
    func play() {
        
        playButton.hidden = true
        stopBtn.hidden = false
        
        audioPlayer.prepareToPlay()
        audioPlayer.enableRate = false
        audioPlayer.stop()
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
    }
    
    func changeAudioTime() {
        audioPlayer.stop()
        audioPlayer.currentTime = NSTimeInterval(audioSlider.value)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
    }
    
    func updateSlider() {
        audioSlider.value = Float(audioPlayer.currentTime)
    }
    
    func finishRecording() {
        audioRecorder.stop()
        audioRecorder = nil
    }
    
}