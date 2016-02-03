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

extension String {
    
    func isEmail() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: .CaseInsensitive)
        return regex?.firstMatchInString(self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }
}

class AccountViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldConfPass: UITextField!
    @IBOutlet weak var textFieldNationality: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var userName: String = ""
    var imagePicker: UIImagePickerController!
    var gender:String = ""
    
    var restPath = "http://server.maplango.com.br/user-rest"
    var myImage = "profile.png"
    var imgPath: String = ""
    
    /*var nationality: String = ""
    let natData = ["Brésil","France","Belgique","Canadá","Portugal"]
    */
    
    //Text field delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*self.pickerView.dataSource = self
        self.pickerView.delegate = self*/
        
        // Do any additional setup after loading the view.
        //_ : CGFloat = 0.7
        //_ : CGFloat = 5.0
        
        scrollView.contentSize.height = 500
        
        textFieldName.backgroundColor = UIColor.clearColor()
        textFieldName.layer.borderWidth = 3.0
        textFieldName.layer.borderColor = UIColor(hex: 0x000000).CGColor
        textFieldName.attributedPlaceholder =
            NSAttributedString(string: "Nom d'utilisateur", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        textFieldEmail.backgroundColor = UIColor.clearColor()
        textFieldEmail.layer.borderWidth = 3.0
        textFieldEmail.layer.borderColor = UIColor(hex: 0x000000).CGColor
        textFieldEmail.attributedPlaceholder =
            NSAttributedString(string: "Email valide", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        textFieldPassword.backgroundColor = UIColor.clearColor()
        textFieldPassword.layer.borderWidth = 3.0
        textFieldPassword.layer.borderColor = UIColor(hex: 0x000000).CGColor
        textFieldPassword.attributedPlaceholder =
            NSAttributedString(string: "Mot de passe", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        textFieldConfPass.backgroundColor = UIColor.clearColor()
        textFieldConfPass.layer.borderWidth = 3.0
        textFieldConfPass.layer.borderColor = UIColor(hex: 0x000000).CGColor
        textFieldConfPass.attributedPlaceholder =
            NSAttributedString(string: "Confirmer mot de passe", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        textFieldNationality.backgroundColor = UIColor.clearColor()
        textFieldNationality.layer.borderWidth = 3.0
        textFieldNationality.layer.borderColor = UIColor(hex: 0x000000).CGColor
        textFieldNationality.attributedPlaceholder =
            NSAttributedString(string: "Nationalité", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        // Custom the visual identity of Image View
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor(hex: 0x000000).CGColor
        imageView.layer.cornerRadius = 45
        imageView.layer.masksToBounds = true
        
        segmentControl.layer.borderWidth = 3
        segmentControl.layer.borderColor = UIColor(hex: 0x000000).CGColor
        segmentControl.layer.cornerRadius = 20
        segmentControl.layer.masksToBounds = true
        
        
    }
    
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        //Hide the keyboard
        textFieldName.resignFirstResponder()
        textFieldEmail.resignFirstResponder()
        textFieldPassword.resignFirstResponder()
        textFieldConfPass.resignFirstResponder()
        textFieldNationality.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        if let selectedImage = info[UIImagePickerControllerOriginalImage] {
            //Set photoImageView to display the selected image
            imageView.image = selectedImage as? UIImage
            // save image in directory
            let imgUtils:ImageUtils = ImageUtils()
            self.imgPath = imgUtils.fileInDocumentsDirectory(self.myImage)
            imgUtils.saveImage(imageView.image!, path: self.imgPath);
        } else {
            print("Ocorreu um erro ao tentar gerar a imagem")
        }
        
        //Dismiss the picker
        dismissViewControllerAnimated(true, completion: nil)
        
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
            
            //Checagem remota
            Alamofire.request(.GET, self.restPath, parameters: ["foo": "bar"])
                .responseSwiftyJSON({ (request, response, json, error) in
                    var isRegistered: Bool = false
                    
                    if let users = json.array {
                        
                        for user in  users{
                            if( user["email"].string! == email ){
                                isRegistered = true
                                break
                            }
                        }
                    }
                    if(isRegistered) {
                        NSLog("@resultado : %@", "FALHOU !!!")
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Ops"
                            alertView.message = "E-mail já utilizado, favor utilize outro!"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        }
                    }else {
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

