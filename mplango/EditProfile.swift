//
//  EditProfile.swift
//  mplango
//
//  Created by Thomas Petit on 05/11/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON
import UIKit

class EditProfile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    var user: RUser!
    var userId:Int!
    
    var gender:String = ""
    var imagePath: String = ""
    var avatar:UIImage!
    
    var indicator:ActivityIndicator = ActivityIndicator()

    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var profPicture: UIImageView!
    @IBOutlet weak var userGender: UISegmentedControl!
    @IBOutlet weak var confirmEditProf: UIBarButtonItem!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userNation: UITextField!
    @IBOutlet weak var userBio: UITextView!
    @IBOutlet weak var maxLenghtLabel: UILabel!
    
    @IBOutlet weak var pickeViewCountries: UIPickerView!
    var nationality: String = ""
    var pickerCountryDataSource = ["Afghanistan", "Afrique du Sud", "Algérie", "Allemagne", "Andorre","Antigua-et-Barbuda", "Anguilla", "Albanie", "Arabie saoudite", "Arménie", "Angola", "Antarctique", "Argentine", "Aruba", "Autriche", "Australie", "Åland (Îles)", "Azerbaïdjan", "Bahamas", "Bahreïn", "Bangladesh", "Barbade", "Belgique", "Belize", "Bénin", "Bermudes", "Bhoutan", "Biélorussie", "Bolivie", "Bosnie-Herzégovine", "Botswana", "Bouvet (Île)", "Brésil", "Brunéi Darussalam", "Bulgarie", "Burkina Faso", "Burundi", "Caïmans (Îles)", "Cambodge", "Cameroun", "Canada", "Cap-Vert", "Chili", "Chine", "Christmas (Île)", "Chypre", "Cocos (Îles)", "Comores", "Congo-Brazzaville", "Congo-Kinshasa", "Cook (Îles)", "Côte d’Ivoire",  "Colombie", "Corée du Nord", "Corée du Sud", "Costa Rica", "Cuba",  "Curaçao", "Croatie", "Danemark", "Djibouti", "Dominique", "Égypte", "El Salvador", "Émirats arabes unis", "Équateur", "Érythrée", "Espagne", "Estonie", "États fédérés de Micronésie", "États-Unis", "Éthiopie", "Féroé (Îles)", "Fidji", "Finlande", "France", "Gabon", "Gambie", "Géorgie", "Géorgie du Sud et îles Sandwich du Sud", "Ghana", "Gibraltar", "Grèce", "Grenade", "Groenland", "Guadeloupe", "Guam", "Guatemala", "Guernesey", "Guinée", "Guinée équatoriale", "Guinée-Bissau", "Guyana", "Guyane française", "Haïti", "Honduras", "Hong Kong", "Heard et McDonald (Îles)", "Hongrie", "Île de Man", "Îles Turques-et-Caïques", "Îles Vierges britanniques", "Îles Vierges des États-Unis", "Inde", "Indonésie", "Irak", "Iran", "Irlande", "Islande", "Israël", "Italie", "Jamaïque", "Japon", "Jersey", "Jordanie", "Kazakhstan", "Kenya", "Kirghizistan", "Kiribati", "Koweït", "Laos", "Lesotho", "Lettonie", "Liban", "Libéria", "Libye", "Liechtenstein", "Lituanie", "Luxembourg", "Macao", "Macédoine", "Madagascar", "Malaisie", "Malawi", "Maldives", "Mali", "Malouines (Îles)", "Malte", "Mariannes du Nord (Îles)", "Maroc", "Marshall (Îles)", "Martinique", "Maurice", "Mauritanie", "Mayotte", "Mexique", "Moldavie", "Monaco", "Mongolie", "Monténégro", "Montserrat", "Mozambique", "Myanmar", "Namibie", "Nauru", "Népal", "Nicaragua", "Niger", "Nigéria", "Niue", "Norfolk (Île)", "Norvège", "Nouvelle-Calédonie", "Nouvelle-Zélande", "Oman", "Ouganda", "Ouzbékistan", "Pakistan", "Palaos", "Panama", "Papouasie-Nouvelle-Guinée", "Paraguay", "Pays-Bas", "Pays-Bas caribéens", "Pérou", "Philippines", "Pitcairn (Îles)", "Pologne", "Polynésie française", "Porto Rico", "Portugal", "Qatar", "Réunion (La)", "République centrafricaine", "République Dominicaine", "République Tchèque", "Roumanie", "Royaume-Uni", "Russie", "Rwanda", "Sahara occidental", "Saint-Barthélemy", "Saint-Christophe-et-Niévès", "Sainte-Hélène", "Sainte-Lucie", "Saint-Marin", "Saint-Martin", "Saint-Martin (partie néerlandaise)", "Saint-Pierre-et-Miquelon", "Salomon (Îles)", "Samoa", "Samoa américaines", "Sao Tomé-et-Principe", "Sénégal", "Serbie", "Seychelles", "Sierra Leone", "Singapour", "Slovaquie", "Slovénie", "Somalie", "Soudan", "Soudan du Sud", "Sri Lanka", "Suède", "Suisse", "Suriname", "Svalbard et Jan Mayen", "Swaziland", "Syrie", "Tadjikistan", "Taïwan", "Tanzanie", "Tchad", "Terres australes françaises", "Territoire britannique de l’océan Indien", "Territoires palestiniens", "Thaïlande", "Timor oriental", "Togo", "Tokelau", "Tonga", "Trinité-et-Tobago", "Tunisie", "Turkménistan", "Turquie", "Tuvalu", "Ukraine", "Uruguay", "Vanuatu", "Vatican", "Venezuela", "Vietnam",  "Wallis-et-Futuna", "Yémen",  "Zambie", "Zimbabwe"];
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        self.upServerUser()
        
        self.pickeViewCountries.dataSource = self
        self.pickeViewCountries.delegate = self
        self.userBio.delegate = self

        pickeViewCountries.hidden = true;

        scroll.contentSize.height = 200
        
        // Enable the Save button only if the screen has a valid change
        checkValidChange()
        
        // Keyboard stuff.
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(EditProfile.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(EditProfile.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        profPicture.layer.cornerRadius = 40
        profPicture.layer.masksToBounds = true
        
        userGender.layer.borderWidth = 3
        userGender.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        userGender.layer.cornerRadius = 20
        userGender.layer.masksToBounds = true

        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditProfile.dismissKeyboard))
        view.addGestureRecognizer(tap)
    
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        pickeViewCountries.hidden = true

    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"  // Recognizes enter key in keyboard
        {
            userBio.resignFirstResponder()
            return false
        }
        
        let limitLength = 149
        guard let text = userBio.text else { return true }
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
    
    //MARK : Countries Picker View
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerCountryDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerCountryDataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        userNation.text = pickerCountryDataSource[row]
        confirmEditProf.enabled = true

        pickeViewCountries.hidden = true;
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == userNation {
            userName.resignFirstResponder()
            userBio.resignFirstResponder()
            pickeViewCountries.hidden = false
            return false
        }
        
        return true
    }

    

    //MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
        
    }
 
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch userGender.selectedSegmentIndex {
        case 0:
            gender = "Homme"
        case 1:
            gender = "Femme"
        default:
            break
        }
        confirmEditProf.enabled = true
    }
    
    @IBAction func confirmEditProf(sender: AnyObject) {
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userId:Int = prefs.integerForKey("id") as Int
        
        let params : [String: String] = [
            "id" : String(userId),
            "name" : self.userName.text!,
            "nationality" : self.userNation.text!,
            "bio" : self.userBio.text!,
            "gender" : self.gender,
        ]
        
        self.indicator.showActivityIndicator(self.view)
        
        if self.avatar != nil {
            self.saveProfile(self.avatar, params: params);
        } else {
            self.saveProfile(params);
        }
        
        
    }
    
    func saveProfile(params: Dictionary<String, String>) {
        Alamofire.request(.POST, EndpointUtils.USER, parameters: params)
            .responseString { response in
                print("Success POST: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }
            .responseSwiftyJSON({ (request, response, json, error) in
                print("Request POST: \(request)")
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("edit_profile", sender: self)
                    }
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Ccontroller
                        let alertController = UIAlertController(title: "Oops", message: "Tivemos um problema ao tentar atualizar seu perfil. Favor tente novamente.", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The profile update is not okay.")
                            self.indicator.hideActivityIndicator();
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            })
    }
    
    func saveProfile(avatar: UIImage, params: Dictionary<String, String>) {
        // example image data
        let imageData = avatar.lowestQualityJPEGNSData
        
        // save image in directory
        self.imagePath = ImageUtils.instance.fileInDocumentsDirectory("profile.png")
        ImageUtils.instance.saveImage(profPicture.image!, path: self.imagePath)
        
        // CREATE AND SEND REQUEST ----------
        let urlRequest = UrlRequestUtils.instance.urlRequestWithComponents(EndpointUtils.USER, parameters: params, imageData: imageData)
        
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseString { response in
                print("Success UPLOAD: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                print("Request UPLOAD: \(request)")
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("edit_profile", sender: self)
                    }
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Ccontroller
                        let alertController = UIAlertController(title: "Oops", message: "Tivemos um problema ao tentar atualizar seu perfil. Favor tente novamente.", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The profile update is not okay.")
                            self.indicator.hideActivityIndicator();
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                
            })
    }
    
    func retrieveLoggedUser() {
        
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", userId)
        
    }
    
    
    //MARK: UIScrollView moves up (textField) when keyboard appears
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        var contentInset:UIEdgeInsets = self.scroll.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scroll.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsetsZero
        self.scroll.contentInset = contentInset
    }
    
    func upServerUser() {
        self.indicator.showActivityIndicator(self.view)
        
        let params : [String: Int] = [
            "id": self.userId,
        ]
        
        //Checagem remota
        Alamofire.request(.GET, EndpointUtils.USER, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                self.indicator.hideActivityIndicator();
                let user = json["data"]
                if let id = user["id"].int {
                    let photo = EndpointUtils.USER + "?id=" + String(id) + "&avatar=true"
                    print("show photo : ",photo)
                    self.profPicture.image = ImageUtils.instance.loadImageFromPath(photo)
                }
                
                if let username = user["name"].string {
                    print("show name : ", username)
                    self.userName.attributedPlaceholder = NSAttributedString(string: username)
                }
                
                if let nat = user["nationality"].string {
                    print("show nationality : ", nat)
                    self.userNation.attributedPlaceholder = NSAttributedString(string: nat)
                }
                
                if let userBio = user["bio"].string {
                    print("show bio : ", userBio)
                    self.userBio.text = (userBio)
                    
                }
                
                if let gen = user["gender"].string {
                    print("show gender : ", gen)
                    if gen == "Homme" {
                        self.userGender.selectedSegmentIndex = 0
                    }
                    else if gen == "Femme" {
                        self.userGender.selectedSegmentIndex = 1
                    }
                }
                
            });
        
    }

    
    
    // MARK : Image Picker Process
    
    var picker:UIImagePickerController? = UIImagePickerController()
    var popover:UIPopoverPresentationController? = nil

    
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        
        //Hide the keyboard
        userName.resignFirstResponder()
        userNation.resignFirstResponder()
        userBio.resignFirstResponder()
        
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
            popover?.barButtonItem = navigationItem.rightBarButtonItem
            popover?.permittedArrowDirections = .Any
            
        }
        
    }
    
    func openCamera() {
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
    
    func openGallary() {
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
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
        profPicture.image = fixOrientationImage
        
        self.avatar = profPicture.image!
        
        confirmEditProf.enabled = true
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("picker cancel.")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: enable confirm button
    
    func textViewDidBeginEditing(textView: UITextView) {
        // Disable the Save button while editing.
        confirmEditProf.enabled = false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        confirmEditProf.enabled = false
    }
    
    func checkValidChange() {
        // Disable the Save button if the text field is empty.
        let text = userName.text ?? ""
        let text2 = userBio.text ?? ""
        
        if (!text.isEmpty) {
            confirmEditProf.enabled = true
        
        } else if (!text2.isEmpty) {
            confirmEditProf.enabled = true

            
        } else {
            confirmEditProf.enabled = false
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidChange()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        checkValidChange()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(scroll, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(scroll, name: UIKeyboardWillHideNotification, object: nil)
    }
    
}