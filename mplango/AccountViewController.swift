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
    
    var restPath = "http://server.maplango.com.br/user-rest"
    var myImage = "profile.png"
    var imgPath: String = ""
    
    
    var nationality: String = ""
    var pickerCountryDataSource = ["Andorre", "Émirats arabes unis", "Afghanistan", "Antigua-et-Barbuda", "Anguilla", "Albanie", "Arménie", "Angola", "Antarctique", "Argentine", "Samoa américaines", "Autriche", "Australie", "Aruba", "Îles Åland", "Azerbaïdjan", "Bosnie-Herzégovine", "Barbade", "Bangladesh", "Belgique", "Burkina Faso", "Bulgarie", "Bahreïn", "Burundi", "Bénin", "Saint-Barthélemy", "Bermudes", "Brunéi Darussalam", "Bolivie", "Pays-Bas caribéens", "Brésil", "Bahamas", "Bhoutan", "Île Bouvet", "Botswana", "Biélorussie", "Belize", "Canada", "Îles Cocos", "Congo-Kinshasa", "République centrafricaine", "Congo-Brazzaville", "Suisse", "Côte d’Ivoire", "Îles Cook", "Chili", "Cameroun", "Chine", "Colombie", "Costa Rica", "Cuba", "Cap-Vert", "Curaçao", "Île Christmas", "Chypre", "République tchèque", "Allemagne", "Djibouti", "Danemark", "Dominique", "République dominicaine", "Algérie", "Équateur", "Estonie", "Égypte", "Sahara occidental", "Érythrée", "Espagne", "Éthiopie", "Finlande", "Fidji", "Îles Malouines", "États fédérés de Micronésie", "Îles Féroé", "France", "Gabon", "Royaume-Uni", "Grenade", "Géorgie", "Guyane française", "Guernesey", "Ghana", "Gibraltar", "Groenland", "Gambie", "Guinée", "Guadeloupe", "Guinée équatoriale", "Grèce", "Géorgie du Sud et îles Sandwich du Sud", "Guatemala", "Guam", "Guinée-Bissau", "Guyana", "R.A.S. chinoise de Hong Kong", "Îles Heard et McDonald", "Honduras", "Croatie", "Haïti", "Hongrie", "Indonésie", "Irlande", "Israël", "Île de Man", "Inde", "Territoire britannique de l’océan Indien", "Irak", "Iran", "Islande", "Italie", "Jersey", "Jamaïque", "Jordanie", "Japon", "Kenya", "Kirghizistan", "Cambodge", "Kiribati", "Comores", "Saint-Christophe-et-Niévès", "Corée du Nord", "Corée du Sud", "Koweït", "Îles Caïmans", "Kazakhstan", "Laos", "Liban", "Sainte-Lucie", "Liechtenstein", "Sri Lanka", "Libéria", "Lesotho", "Lituanie", "Luxembourg", "Lettonie", "Libye", "Maroc", "Monaco", "Moldavie", "Monténégro", "Saint-Martin", "Madagascar", "Îles Marshall", "Macédoine", "Mali", "Myanmar", "Mongolie", "R.A.S. chinoise de Macao", "Îles Mariannes du Nord", "Martinique", "Mauritanie", "Montserrat", "Malte", "Maurice", "Maldives", "Malawi", "Mexique", "Malaisie", "Mozambique", "Namibie", "Nouvelle-Calédonie", "Niger", "Île Norfolk", "Nigéria", "Nicaragua", "Pays-Bas", "Norvège", "Népal", "Nauru", "Niue", "Nouvelle-Zélande", "Oman", "Panama", "Pérou", "Polynésie française", "Papouasie-Nouvelle-Guinée", "Philippines", "Pakistan", "Pologne", "Saint-Pierre-et-Miquelon", "Îles Pitcairn", "Porto Rico", "Territoires palestiniens", "Portugal", "Palaos", "Paraguay", "Qatar", "La Réunion", "Roumanie", "Serbie", "Russie", "Rwanda", "Arabie saoudite", "Îles Salomon", "Seychelles", "Soudan", "Suède", "Singapour", "Sainte-Hélène", "Slovénie", "Svalbard et Jan Mayen", "Slovaquie", "Sierra Leone", "Saint-Marin", "Sénégal", "Somalie", "Suriname", "Soudan du Sud", "Sao Tomé-et-Principe", "El Salvador", "Saint-Martin (partie néerlandaise)", "Syrie", "Swaziland", "Îles Turques-et-Caïques", "Tchad", "Terres australes françaises", "Togo", "Thaïlande", "Tadjikistan", "Tokelau", "Timor oriental", "Turkménistan", "Tunisie", "Tonga", "Turquie", "Trinité-et-Tobago", "Tuvalu", "Taïwan", "Tanzanie", "Ukraine", "Ouganda", "Îles mineures éloignées des É.-U.", "États-Unis", "Uruguay", "Ouzbékistan", "État de la Cité du Vatican", "Saint-Vincent-et-les-Grenadines", "Venezuela", "Îles Vierges britanniques", "Îles Vierges des États-Unis", "Vietnam", "Vanuatu", "Wallis-et-Futuna", "Samoa", "Yémen", "Mayotte", "Afrique du Sud", "Zambie", "Zimbabwe"];
    
    
    
    
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
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        
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
        pickeViewCountries.hidden = true;
        return pickerCountryDataSource[row]
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == textFieldNationality {
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
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        // save image in directory
        let imgUtils:ImageUtils = ImageUtils()
        self.imgPath = imgUtils.fileInDocumentsDirectory(self.myImage)
        imgUtils.saveImage(imageView.image!, path: self.imgPath);
        
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
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "É necessário escolher o seu gênero"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else if ( username.isEmpty ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "O nome é obrigatório"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else if ( email.isEmpty ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "Campo email obrigatório"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else if (!email.isEmail()) {
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "Pr favor, insira um email válido"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else if ( password.isEmpty  ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "Campo senha é obrigatório"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else if ( !password.isEmpty  && confirmPassword.isEmpty) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "É necessário confirmar sua senha"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else if (password != confirmPassword) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "A senha não confere com a confirmação"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else if ( nationality.isEmpty ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "É necessário escolher sua nacionalidade"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else {
            self.indicator.showActivityIndicator(self.view)
            //Checagem remota
            Alamofire.request(.GET, self.restPath, parameters: ["email": email])
                .responseSwiftyJSON({ (request, response, json, error) in
                    if json["data"].array?.count > 0 {
                        NSLog("@resultado : %@", "EMAIL JÁ EXISTENTE NO BANCO DE DADOS!!!")
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Ops"
                            alertView.message = "E-mail já utilizado, favor utilize outro!"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        }
                    } else {
                        let params : [String: AnyObject] = [
                            "name" : self.textFieldName.text!,
                            "email" : self.textFieldEmail.text!,
                            "password" : self.textFieldPassword.text!,
                            "gender" : self.gender,
                            "nationality" : nationality,
                            "level" : 7,
                            "image" : self.imgPath
                        ]
                        Alamofire.request(.POST, self.restPath, parameters: params)
                            .responseSwiftyJSON({ (request, response, json, error) in
                                if (error == nil) {
                                    self.indicator.hideActivityIndicator();
                                    NSOperationQueue.mainQueue().addOperationWithBlock {
                                        self.performSegueWithIdentifier("account_to_login", sender: self)
                                    }
                                }
                            })
                        
                        //TODO - sincronizar com o coredata
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

