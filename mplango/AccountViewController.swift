//

//  ViewController.swift
//  mplango
//
//  Created by Bruno Ferreira on 11/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

extension String {
    
    func isEmail() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: .CaseInsensitive)
        return regex?.firstMatchInString(self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }
}

class AccountViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldConfPass: UITextField!
    @IBOutlet weak var textFieldNationality: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickeViewCountries: UIPickerView!
    
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    
    var userName: String = ""
    var imagePicker: UIImagePickerController!
    var gender:String = ""
    var indicator:ActivityIndicator = ActivityIndicator()
    
    var myImage = "profile.png"
    var imgPath: String = ""
    var avatar:UIImage!
    
    
    var nationality: String = ""
    var pickerCountryDataSource = ["Afghanistan", "Afrique du Sud", "Algérie", "Allemagne", "Andorre","Antigua-et-Barbuda", "Anguilla", "Albanie", "Arabie saoudite", "Arménie", "Angola", "Antarctique", "Argentine", "Aruba", "Autriche", "Australie", "Åland (Îles)", "Azerbaïdjan", "Bahamas", "Bahreïn", "Bangladesh", "Barbade", "Belgique", "Belize", "Bénin", "Bermudes", "Bhoutan", "Biélorussie", "Bolivie", "Bosnie-Herzégovine", "Botswana", "Bouvet (Île)", "Brésil", "Brunéi Darussalam", "Bulgarie", "Burkina Faso", "Burundi", "Caïmans (Îles)", "Cambodge", "Cameroun", "Canada", "Cap-Vert", "Chili", "Chine", "Christmas (Île)", "Chypre", "Cocos (Îles)", "Comores", "Congo-Brazzaville", "Congo-Kinshasa", "Cook (Îles)", "Côte d’Ivoire",  "Colombie", "Corée du Nord", "Corée du Sud", "Costa Rica", "Cuba",  "Curaçao", "Croatie", "Danemark", "Djibouti", "Dominique", "Égypte", "El Salvador", "Émirats arabes unis", "Équateur", "Érythrée", "Espagne", "Estonie", "États fédérés de Micronésie", "États-Unis", "Éthiopie", "Féroé (Îles)", "Fidji", "Finlande", "France", "Gabon", "Gambie", "Géorgie", "Géorgie du Sud et îles Sandwich du Sud", "Ghana", "Gibraltar", "Grèce", "Grenade", "Groenland", "Guadeloupe", "Guam", "Guatemala", "Guernesey", "Guinée", "Guinée équatoriale", "Guinée-Bissau", "Guyana", "Guyane française", "Haïti", "Honduras", "Hong Kong", "Heard et McDonald (Îles)", "Hongrie", "Île de Man", "Îles Turques-et-Caïques", "Îles Vierges britanniques", "Îles Vierges des États-Unis", "Inde", "Indonésie", "Irak", "Iran", "Irlande", "Islande", "Israël", "Italie", "Jamaïque", "Japon", "Jersey", "Jordanie", "Kazakhstan", "Kenya", "Kirghizistan", "Kiribati", "Koweït", "Laos", "Lesotho", "Lettonie", "Liban", "Libéria", "Libye", "Liechtenstein", "Lituanie", "Luxembourg", "Macao", "Macédoine", "Madagascar", "Malaisie", "Malawi", "Maldives", "Mali", "Malouines (Îles)", "Malte", "Mariannes du Nord (Îles)", "Maroc", "Marshall (Îles)", "Martinique", "Maurice", "Mauritanie", "Mayotte", "Mexique", "Moldavie", "Monaco", "Mongolie", "Monténégro", "Montserrat", "Mozambique", "Myanmar", "Namibie", "Nauru", "Népal", "Nicaragua", "Niger", "Nigéria", "Niue", "Norfolk (Île)", "Norvège", "Nouvelle-Calédonie", "Nouvelle-Zélande", "Oman", "Ouganda", "Ouzbékistan", "Pakistan", "Palaos", "Panama", "Papouasie-Nouvelle-Guinée", "Paraguay", "Pays-Bas", "Pays-Bas caribéens", "Pérou", "Philippines", "Pitcairn (Îles)", "Pologne", "Polynésie française", "Porto Rico", "Portugal", "Qatar", "Réunion (La)", "République centrafricaine", "République Dominicaine", "République Tchèque", "Roumanie", "Royaume-Uni", "Russie", "Rwanda", "Sahara occidental", "Saint-Barthélemy", "Saint-Christophe-et-Niévès", "Sainte-Hélène", "Sainte-Lucie", "Saint-Marin", "Saint-Martin", "Saint-Martin (partie néerlandaise)", "Saint-Pierre-et-Miquelon", "Salomon (Îles)", "Samoa", "Samoa américaines", "Sao Tomé-et-Principe", "Sénégal", "Serbie", "Seychelles", "Sierra Leone", "Singapour", "Slovaquie", "Slovénie", "Somalie", "Soudan", "Soudan du Sud", "Sri Lanka", "Suède", "Suisse", "Suriname", "Svalbard et Jan Mayen", "Swaziland", "Syrie", "Tadjikistan", "Taïwan", "Tanzanie", "Tchad", "Terres australes françaises", "Territoire britannique de l’océan Indien", "Territoires palestiniens", "Thaïlande", "Timor oriental", "Togo", "Tokelau", "Tonga", "Trinité-et-Tobago", "Tunisie", "Turkménistan", "Turquie", "Tuvalu", "Ukraine", "Uruguay", "Vanuatu", "Vatican", "Venezuela", "Vietnam",  "Wallis-et-Futuna", "Yémen",  "Zambie", "Zimbabwe"];
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickeViewCountries.dataSource = self
        self.pickeViewCountries.delegate = self
        
        pickeViewCountries.hidden = true;
        textFieldNationality.text = pickerCountryDataSource[0]
        
        //let countryUtils:CountryUtils = CountryUtils()
        //self.pickerCountryDataSource = countryUtils.getList("fr_FR");
        
        // Do any additional setup after loading the view.
        //_ : CGFloat = 0.7
        //_ : CGFloat = 5.0
        
        scrollView.contentSize.height = 300
        
        // Keyboard stuff.
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(AccountViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(AccountViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        
        textFieldName.backgroundColor = UIColor.clearColor()
        textFieldName.layer.borderWidth = 3.0
        textFieldName.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        textFieldName.attributedPlaceholder =
            NSAttributedString(string: "Nom d'utilisateur", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        textFieldEmail.backgroundColor = UIColor.clearColor()
        textFieldEmail.layer.borderWidth = 3.0
        textFieldEmail.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        textFieldEmail.attributedPlaceholder =
            NSAttributedString(string: "Email valide", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        textFieldPassword.backgroundColor = UIColor.clearColor()
        textFieldPassword.layer.borderWidth = 3.0
        textFieldPassword.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        textFieldPassword.attributedPlaceholder =
            NSAttributedString(string: "Mot de passe", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        textFieldConfPass.backgroundColor = UIColor.clearColor()
        textFieldConfPass.layer.borderWidth = 3.0
        textFieldConfPass.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        textFieldConfPass.attributedPlaceholder =
            NSAttributedString(string: "Confirmer mot de passe", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        textFieldNationality.backgroundColor = UIColor.clearColor()
        textFieldNationality.layer.borderWidth = 3.0
        textFieldNationality.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        textFieldNationality.attributedPlaceholder =
            NSAttributedString(string: "Nationalité", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        // Custom the visual identity of Image View
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        imageView.layer.cornerRadius = 45
        imageView.layer.masksToBounds = true
        
        segmentControl.layer.borderWidth = 3
        segmentControl.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        segmentControl.layer.cornerRadius = 20
        segmentControl.layer.masksToBounds = true
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AccountViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        pickeViewCountries.hidden = true

    }
    
    
    //MARK : Countries Picker View
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerCountryDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        textFieldNationality.text = pickerCountryDataSource[row]
        return pickerCountryDataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        textFieldNationality.text = pickerCountryDataSource[row]
        pickeViewCountries.hidden = true;
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == textFieldNationality {
            textFieldName.resignFirstResponder()
            textFieldEmail.resignFirstResponder()
            textFieldPassword.resignFirstResponder()
            textFieldConfPass.resignFirstResponder()
            pickeViewCountries.hidden = false
            return false
        }
        return true
    }
    
    
    // MARK : Image Picker Process
    
    var picker:UIImagePickerController? = UIImagePickerController()
    var popover:UIPopoverPresentationController? = nil
    
    
    
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        
        //Hide the keyboard
        textFieldName.resignFirstResponder()
        textFieldEmail.resignFirstResponder()
        textFieldPassword.resignFirstResponder()
        textFieldConfPass.resignFirstResponder()
        textFieldNationality.resignFirstResponder()
        
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
        imageView.image = fixOrientationImage

        // save image in memory
        self.avatar = imageView.image!
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("picker cancel.")
        dismissViewControllerAnimated(true, completion: nil)
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
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInset
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            gender = "Homme"
        case 1:
            gender = "Femme"
        default:
            break
        }
    }
    
    @IBAction func saveTapped(sender: AnyObject) {
        
        let username: String = textFieldName.text! as String
        let email: String = textFieldEmail.text! as String
        let password: String = textFieldPassword.text!
        let confirmPassword: String = textFieldConfPass.text!
        let nationality: String = textFieldNationality.text!
        
        
        if ( gender.isEmpty ) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Erro ao tentar Registrar os Dados!", message: "É necessário escolher o seu gênero", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
        } else if ( username.isEmpty ) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Erro ao tentar Registrar os Dados!", message: "O nome é obrigatório", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
        } else if ( email.isEmpty ) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Erro ao tentar Registrar os Dados!", message: "Campo email obrigatório", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
        } else if (!email.isEmail()) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Erro ao tentar Registrar os Dados!", message: "Por favor, insira um email válido", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
        } else if ( password.isEmpty  ) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Erro ao tentar Registrar os Dados!", message: "Campo senha é obrigatório", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
        } else if ( !password.isEmpty  && confirmPassword.isEmpty) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Erro ao tentar Registrar os Dados!", message: "É necessário confirmar sua senha", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
        } else if (password != confirmPassword) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Erro ao tentar Registrar os Dados!", message: "A senha não confere com a confirmação", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
        } else if ( nationality.isEmpty ) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Erro ao tentar Registrar os Dados!", message: "É necessário escolher sua nacionalidade", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
        } else {
            self.indicator.showActivityIndicator(self.view)
            //Checagem remota
            Alamofire.request(.GET, EndpointUtils.USER, parameters: ["email": email])
                .responseSwiftyJSON({ (request, response, json, error) in
                    if json["data"].array?.count > 0 {
                        NSLog("@resultado : %@", "EMAIL JÁ EXISTENTE NO BANCO DE DADOS!!!")
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.indicator.hideActivityIndicator();
                            //New Alert Ccontroller
                            let alertController = UIAlertController(title: "Oops", message: "E-mail já utilizado, favor utilize outro!", preferredStyle: .Alert)
                            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                                print("The user is okay.")
                            }
                            alertController.addAction(agreeAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                            
                        }
                    } else {
                        let params : [String: String] = [
                            "name" : self.textFieldName.text!,
                            "email" : self.textFieldEmail.text!,
                            "password" : self.textFieldPassword.text!,
                            "gender" : self.gender,
                            "nationality" : String(nationality),
                            "level" : String(7)
                        ]
                        
                        // example image data
                        let image = self.avatar
                        let imageData = image.lowestQualityJPEGNSData
                        
                        
                        // CREATE AND SEND REQUEST ----------
                        let urlRequest = UrlRequestUtils.instance.urlRequestWithComponents(EndpointUtils.USER, parameters: params, imageData: imageData)
                        
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
                                        self.performSegueWithIdentifier("account_to_login", sender: self)
                                    }
                                }
                        })
                    }
                })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "account_to_login" {//
            let loginVC:LoginViewController = segue.destinationViewController as! LoginViewController
            loginVC.registered = true
        }
    }
    
    @IBAction func cancelTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

