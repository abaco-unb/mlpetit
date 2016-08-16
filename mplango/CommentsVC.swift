//
//  CommentsVC.swift
//  mplango
//
//  Created by Thomas Petit on 10/12/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

class CommentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UIPopoverPresentationControllerDelegate, AVAudioRecorderDelegate {

    // MARK: Properties
    var audioPlayer: AVAudioPlayer!
    var recordedAudio:RecordedAudio!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var audioPath:String = ""
    
    var tapper: UITapGestureRecognizer?
    
    var comments: Array<Comment> = [Comment]()
    
    var liked:Bool = false
    var likedId:Int!
    
    var user: RUser!
    var userId:Int!
    var postId:Int = 0
    
    let basicCellIdentifier = "BasicCell"
    
    @IBOutlet weak var creatingContentView: UIView!
    @IBOutlet weak var comTableView: UITableView!

    @IBOutlet weak var writeTxtView: UITextView!
    @IBOutlet weak var writeHereImage: UIImageView!
    
    @IBOutlet weak var comPicture: UIImageView!
    @IBOutlet weak var picBtn: UIButton!
    
    @IBOutlet weak var removeImage: UIButton!
    
    @IBOutlet weak var postComBtn: UIButton!

    //Outlet de áudio do RECORD
    @IBOutlet weak var recordView: UIView!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var iconAudio: UIImageView!
    @IBOutlet weak var labelRecording: UILabel!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.retrieveLoggedUser()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CommentsVC.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        print("teste 1")
        
        initRecorder()
        print("teste 2")
        //print(self.postId)
        
        ActivityIndicator.instance.showActivityIndicator(self.view)
        Alamofire.request(.GET, EndpointUtils.COMMENT, parameters: ["post" : String(self.postId)])
            .responseSwiftyJSON({ (request, response, json, error) in
                ActivityIndicator.instance.hideActivityIndicator()
                if let comments = json["data"].array {
                    for comment in comments {
                        var comId = 0;
                        var comLikes = 0;
                        
                        if let id = comment["id"].int {
                            comId = id
                        }
                        
                        if let likes = comment["likes"].array?.count {
                            comLikes = likes
                            
                            for userId in comment["likes"].array! {
                                print("user comment", userId.numberValue)
                            }
                        }
                        
                        
                        self.comments.append(Comment(id: comId,
                            audio: comment["audio"].stringValue,
                            text: comment["text"].stringValue,
                            image: comment["image"].stringValue,
                            postId: self.postId,
                            created: comment["created"]["date"].stringValue,
                            userId: Int( comment["user"]["id"].stringValue )!,
                            userName: comment["user"]["name"].stringValue,
                            likes: comLikes,
                            liked: false
                            ))
                        
                        print("*************")
                        print(self.comments)
                        print("*************")
                        
                    }
                    
                }
                
                self.comTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
                
                self.writeTxtView.delegate = self
                
                self.comTableView.reloadData()
                
                print("numero de comentarios: ", self.comments.count)
                
                //
                //        if comment != nil {
                //            writeTxtView.text = comment?.text
                //        }
                
        });
        
        //Para que a view acompanhe o teclado e poder escrever o comentário
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentsVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentsVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        self.writeTxtView.delegate = self
        
        self.postComBtn.hidden = true
        self.removeImage.hidden = true
        
        self.recordView.hidden = true
        
        self.comTableView.rowHeight = UITableViewAutomaticDimension
        self.comTableView.estimatedRowHeight = 350.0
        
    }
    
    func retrieveLoggedUser() {
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        
    }


    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        
        writeTxtView.text = nil
        writeHereImage.hidden = false
        postComBtn.hidden = true
        comPicture.image = nil
        removeImage.hidden = true
        picBtn.hidden = false
        recordBtn.hidden = false
        
//        let text = writeTxtView.text
//        
//        if text.characters.count >= 1 {
//            postComBtn.hidden = false
//            postComBtn.enabled = true
//            recordBtn.hidden = true
//        }
//        
//        else if text.characters.count < 1 {
//            writeHereImage.hidden = false
//            recordBtn.hidden = false
//            recordBtn.enabled = true
//            postComBtn.hidden = true
//            postComBtn.enabled = false
//        }
//        
//        textViewDidChange(writeTxtView)

    }
    
    // MARK : UITextView functions
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let limitLength = 149
        guard let text = writeTxtView.text else { return true }
        let newLength = text.characters.count - range.length
        
        return newLength <= limitLength
    }
    
    func textViewDidChange(textView: UITextView) {
        
        let text = writeTxtView.text
        
        if text.characters.count >= 1 {
            postComBtn.hidden = false
            postComBtn.enabled = true
            recordBtn.hidden = true
        }
        
        else if text.characters.count == 0 {
            
            if comPicture != nil {
                postComBtn.hidden = false
                //recordBtn.hidden = true
                //recordBtn.enabled = false
            }
            
            else {
                postComBtn.hidden = true
                recordBtn.hidden = false
                recordBtn.enabled = true
            }
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        writeHereImage.hidden = true
    }
    
    
    // MARK Actions:
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK:- Posting Comment
    @IBAction func postingComment(sender: AnyObject) {
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userId:Int = prefs.integerForKey("id") as Int
        
        let params : [String: String] = [
            "text" : writeTxtView.text,
            "post" : String(self.postId),
            "user": String(userId),
            //"image": String(self.image)
        ]
        
        print("post", String(self.postId), "user", String(userId))
        print("Audio", AudioHelper.instance.audioPath)
        
        if(self.image != nil || self.audioPath != "") {
            self.postCommentMidia(params)
        } else {
            self.postComment(params)
        }
        
        // Gamification: contar 5 pontos aqui para a ação de postar 1 comentário
    }
    
    // MARK : Image Picker Process
    
    var picker:UIImagePickerController? = UIImagePickerController()
    var popover:UIPopoverPresentationController? = nil
    
    
    @IBAction func removeImage(sender: AnyObject) {
        
        comPicture.image = nil
        removeImage.hidden = true
        picBtn.hidden = false
        
        let text = writeTxtView.text
        
        if text.characters.count >= 1 {
            postComBtn.hidden = false
            postComBtn.enabled = true
            recordBtn.hidden = true
            recordBtn.enabled = false
        }
            
        else if text.characters.count < 1 {
            postComBtn.hidden = true
            postComBtn.enabled = false
            recordBtn.hidden = false
            recordBtn.enabled = true
        }
        
    }
    
    @IBAction func selectImageFromPhotoLibrary(sender: UIButton) {
        //Hide the keyboard
        
        writeTxtView.resignFirstResponder()
        
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
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(alert, animated: true, completion: nil)
       
        } else {
            popover = UIPopoverPresentationController(presentedViewController: alert, presentingViewController: alert)
            popover?.sourceView = self.view
            popover?.barButtonItem = navigationItem.rightBarButtonItem
            popover?.permittedArrowDirections = .Any
        }
    }
    
    func openCamera() {
        
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(picker!, animated: true, completion: nil)
            } else {
            openGallary()
            }
        }
    
    func openGallary() {

        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(picker!, animated: true, completion: nil)
        } else {
            popover = UIPopoverPresentationController(presentedViewController: picker!, presentingViewController: picker!)
            
            popover?.sourceView = self.view
            popover?.barButtonItem = navigationItem.rightBarButtonItem
            popover?.permittedArrowDirections = .Any
        }
    }
   
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)

        let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        let fixOrientationImage = chosenImage!.fixOrientation()
        comPicture.image = fixOrientationImage
        
        // save image in memory
        self.image = comPicture.image!
        
        picBtn.hidden = true
        removeImage.hidden = false
        postComBtn.hidden = false
        postComBtn.enabled = true
        recordBtn.hidden = true
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("picker cancel.")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func afterPosting(json: JSON) {
        writeTxtView.resignFirstResponder()
        writeTxtView.text = nil
        postComBtn.hidden = true
        recordBtn.hidden = false
        recordBtn.enabled = true
        writeHereImage.hidden = false
        
        // para zerar as mídias
        image = nil
        audioPath = ""
        
        if self.comPicture != nil {
            self.removeImage(self)
        }
        
        var id: Int = 0
        var uId: Int = 0
        var uName: String = "Pas trouvé"
        
        var tlikes: Int = 0
        
        if let commentId = json["data"]["id"].int {
            id = commentId
        }
        
        if let total = json["data"]["likes"].array?.count {
            tlikes = total
            
        }
        
        if let commentUser = json["data"]["user"]["id"].int {
            uId = commentUser
        }
        
        if let commentUserName = json["data"]["user"]["name"].string {
            uName = commentUserName
        }
        
        let comment = Comment(id: id, audio: json["data"]["audio"].stringValue, text: json["data"]["text"].stringValue, image: json["data"]["image"].stringValue, postId: self.postId, created: json["data"]["created"]["date"].stringValue, userId: uId, userName: uName, likes: tlikes, liked: false)
        
        comments.append(comment)
        comTableView.reloadData()
        
    }

    func postComment(params: Dictionary<String, String>) {
        ActivityIndicator.instance.showActivityIndicator(self.view)
        Alamofire.request(.POST, EndpointUtils.COMMENT, parameters: params)
            .responseString { response in
                print("Request: \(EndpointUtils.COMMENT)")
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                ActivityIndicator.instance.hideActivityIndicator();
                print("Request: \(request)")
                print("request: \(error)")
                if (error == nil) {
                    self.afterPosting(json)
                    
                } else {
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Controller
                        let alertController = UIAlertController(title: "Oups", message: "Ton commentaire n'a pas pu être publié. Essaie à nouveau", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "D'accord", style: .Default) { (action) -> Void in
                            print("The post is not okay.")
                            ActivityIndicator.instance.hideActivityIndicator();
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            })
    }
    
    func postCommentMidia(params: Dictionary<String, String>) {
        
        ActivityIndicator.instance.showActivityIndicator(self.view)
        
        // CREATE AND SEND REQUEST ----------
        
        let urlRequest = self.urlRequestWithComponents(EndpointUtils.COMMENT, parameters: params, data: true)
        
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseString { response in
                print("Request: \(EndpointUtils.COMMENT)")
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                ActivityIndicator.instance.hideActivityIndicator();
                if (error == nil) {
                    self.afterPosting(json)
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Controller
                        let alertController = UIAlertController(title: "Oups", message: "Ton commentaire n'a pas pu être publié. Essaie à nouveau", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "D'accord", style: .Default) { (action) -> Void in
                            print("The comment is fail.")
                            ActivityIndicator.instance.hideActivityIndicator();
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
        if self.audioPath != "" {
            print(self.recordedAudio.filePathUrl)
            print("soundData")
            let soundData = NSData(contentsOfURL: self.recordedAudio.filePathUrl)
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
    
    
    
    
    // Table view
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath) as! CommentCell
        
        cell.comment = comments[indexPath.row] as Comment
        cell.userId = self.userId
        
        let text = comments[indexPath.row].text
        let image: String = comments[indexPath.row].image as String
        let audio: String = comments[indexPath.row].audio as String
        
        cell.userName.text = String(comments[indexPath.row].userName)
        cell.dateLabel.text = String(comments[indexPath.row].created)
        cell.profilePicture.image = ImageUtils.instance.loadImageFromPath(EndpointUtils.USER + "?id=" + String(comments[indexPath.row].userId)  + "&avatar=true" )
        
        cell.likeNberLabel.text =  String(comments[indexPath.row].likes)
        
        // Se tiver texto:
        if text != "" {
            cell.comTxtView.text = comments[indexPath.row].text
        }
        else {
            cell.comTxtView.text = ""
        }
        print("aqui", image)
        
        // Se tiver imagem:
        if image != "" {
            cell.comPicture.image = ImageUtils.instance.loadImageFromPath(EndpointUtils.COMMENT + "?id=" + String(comments[indexPath.row].id)  + "&image=true" )
            let aspectRatioImageViewConstraint = NSLayoutConstraint(item: cell.comPicture, attribute: .Height, relatedBy: .Equal, toItem: cell.comPicture, attribute: .Width, multiplier: 1/1, constant: 1)
            cell.comPicture.addConstraint(aspectRatioImageViewConstraint)
        }
        
        print("Audio CEll : ", audio)
        
        // Se tiver áudio
        if audio != "" {
             print("1 audio")
            //cell.bgPlayerAudioInPhoto.layer.backgroundColor = UIColor(hex: 0xFFFFFF).CGColor
            //cell.bgPlayerAudioInPhoto.layer.masksToBounds = true
            print("2 audio")
            
            cell.audioView.layer.cornerRadius = 10
            cell.audioView.layer.masksToBounds = true
            cell.audioView.layer.borderWidth = 1
            cell.audioView.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
            
            
            print("3 audio", EndpointUtils.COMMENT + "?id=" + String(comments[indexPath.row].id) + "&audio=true")
            let audioHelper: AudioHelper = AudioHelper()
            audioHelper._init(cell.audioView, audioPath: EndpointUtils.COMMENT + "?id=" + String(comments[indexPath.row].id) + "&audio=true")
            print("4 audio")
        }
        
        
        // Para decidir se o usuário vai ver o label "+5pts" ou o botão like
        if comments[indexPath.row].userId == userId {
            cell.likeBtn.enabled = false
            cell.likeBtn.hidden = true
            cell.likeNberLabel.hidden = true
            cell.checkPointsLabel.hidden = false
        }
        else {
            cell.likeBtn.enabled = true
            cell.likeBtn.hidden = false
            cell.checkPointsLabel.hidden = true
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
   
    /** @TODO Pra verificar uma melhor maneira de adicionar esses recursos aqui */
    
    func initRecorder() {
        self.recordingSession = AVAudioSession.sharedInstance()
        self.recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if allowed {
                    print("habilitou o botão")
                    self.loadRecordingGesture()
                } else {
                    NSLog("Error: viewDidLoad -> microfone indisponível")
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        
                        //New Alert Ccontroller
                        let alertController = UIAlertController(title: "Oups!", message: "MapLango doit être autorisé à accéder au microphone", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "D'accord", style: .Default) { (action) -> Void in
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
    }
    
    func loadRecordingGesture(){
        
        //LongPress para a criação de post
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.2
        print("add Gesture par o botão rec ")
        self.recordBtn.addGestureRecognizer(longPressRecogniser)
    }
    
    func handleLongPress(gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state == .Began {
            print("iniciar a gravação")
            recording()
            self.recordBtn.enabled = false
        }
        
        if gestureRecognizer.state == .Ended {
            print("parar a gravação")
            
            do {
                let alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beep-recorded", ofType: "wav")!)
                try audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, fileTypeHint: nil)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
            } catch {
                NSLog("Error: ")
            }
            
            audioRecorder.stop()
            AVAudioSession.sharedInstance()
            
            self.recordBtn.enabled = true
            
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder,successfully flag: Bool) {
        if(flag) {
            do {
                print(" audioRecorderDidFinishRecording")
                
                   let alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beep-recorded", ofType: "wav")!)
                   try audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, fileTypeHint: nil)
                   audioPlayer.prepareToPlay()
                   audioPlayer.play()
                
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
                self.audioPath = recorder.url.description
                
                
                recordView.hidden = false
                
                //Aqui vamos postar o audio...
                print("POSTAR PRO SERVER...")
                self.postingComment(self.recordBtn)
                
                
            } catch {
                fatalError("Failure to ...: \(error)")
            }
        } else {
            NSLog("Error: func audioRecorderDidFinishRecording")
            finishRecording()
            //recordButton.enabled = true
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
            
            recordView.hidden = false
            
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            
        } catch {
            NSLog("Error: func recording")
            finishRecording()
        }
    }
    
    func blinkComponent(comp: UIView) {
        comp.alpha = 0;
        UIView.animateWithDuration(0.7, delay: 0.0, options: [.Repeat, .Autoreverse, .CurveEaseInOut], animations:
            {
                comp.alpha = 1
            }, completion: nil)
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
    
    func finishRecording() {
        audioRecorder.stop()
        audioRecorder = nil
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
//        if(segue.identifier == "to_like_notif"){
//            let navigationController = segue.destinationViewController as! UINavigationController
//            let likeController:LikeViewController = navigationController.viewControllers[0] as! LikeViewController
//            
//            // aqui importar a foto do autor do comentário
////            likeController.likedUser.image = ImageUtils.instance.loadImageFromPath(EndpointUtils.USER + "?id=" + String(comments(userId))  + "&avatar=true" )
//                        
//            likeController.likingUser.image = UIImage(contentsOfFile: self.user.image)
//            
//        }
    }
    
    
    
    
}