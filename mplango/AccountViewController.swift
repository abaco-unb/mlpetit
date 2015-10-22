//

//  ViewController.swift
//  mplango
//
//  Created by Bruno Ferreira on 11/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

extension String {
    
    func isEmail() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: .CaseInsensitive)
        return regex?.firstMatchInString(self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }
}

class AccountViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldConfPass: UITextField!
    @IBOutlet weak var textFieldNationality: UITextField!

    /*@IBOutlet weak var pickerView: UIPickerView!*/
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePhoto: UIButton!
    @IBOutlet weak var libraryPhoto: UIButton!
    
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var userName: String = ""
    var imagePicker: UIImagePickerController!
    var gender:String = ""
    
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
        
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
    }
    
    @IBAction func libraryPhoto(sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        
        
    }
    
    @IBAction func takePhoto(sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
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
        
        
        if ( username.isEmpty ) {
            
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
            
        } else if ( password.isEmpty  || confirmPassword.isEmpty) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "Campo senha obrigatório"
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
            
        } else if ( gender.isEmpty ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "É necessário escolher o seu gênero"
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
            
            //Recuperando o Delegate do projeto
            let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            //Recuperando o contexto dos objetos do CoreData
            let contxt: NSManagedObjectContext = appDel.managedObjectContext!
            
            
            let fetchRequest = NSFetchRequest(entityName: "User")
            let predicate = NSPredicate(format: "name == %@ && email == %@", textFieldName.text!, textFieldEmail.text!)
            fetchRequest.predicate = predicate
            
            if let fetchResults = (try? contxt.executeFetchRequest(fetchRequest)) as? [User] {
                if (fetchResults.count > 0) {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "Erro ao tentar Registrar os Dados!"
                    alertView.message = "Conta já cadastrada em nosso banco de dados"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                } else {
                    
                    // Preparando a entidade User para a adição de registros
                    let en = NSEntityDescription.entityForName("User", inManagedObjectContext: contxt)
                    
                    //Criando uma nova instância de dados para inserção
                    let newUser = User(entity: en!, insertIntoManagedObjectContext: contxt)
                    
                    //Salvando nosso contexto
                    newUser.name = textFieldName.text!
                    newUser.email = textFieldEmail.text!
                    newUser.password = textFieldPassword.text!
                    newUser.gender = gender
                    newUser.nationality = nationality
                    newUser.profile = 1
                    newUser.image = UIImageJPEGRepresentation(imageView.image!, 1)!
                    print(newUser)
                    do {
                        try contxt.save()
                    } catch _ {
                    }
                    
                    let post:NSString = "name=\(username)&mail=\(email)&password=\(password)&gender=\(gender)&nationality=\(nationality)"
                    
                    NSLog("PostData: %@",post);
                    
                    let url:NSURL = NSURL(string: "http://service.maplango.com.br/user")!
                    
                    let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
                    
                    let postLength:NSString = String( postData.length )
                    
                    let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
                    request.HTTPMethod = "POST"
                    request.HTTPBody = postData
                    request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    request.setValue("application/json", forHTTPHeaderField: "Accept")
                    
                    
                    var reponseError: NSError?
                    var response: NSURLResponse?
                    
                    var urlData: NSData?
                    do {
                        urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
                    } catch let error as NSError {
                        reponseError = error
                        urlData = nil
                    }
                    
                    print(urlData);
                    
                    if ( urlData != nil ) {
                        let res = response as! NSHTTPURLResponse!;
                        
                        NSLog("Response code: %ld", res.statusCode);
                        
                        if (res.statusCode >= 200 && res.statusCode < 300)
                        {
                            let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                            
                            NSLog("Response ==> %@", responseData);
                            
                            var error: NSError?
                            
                            let jsonData:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers )) as! NSDictionary
                            
                            let success: String = jsonData.valueForKey("id") as! String
                            
                            NSLog("Success: %ld", success);
                            
                            if(success != "")
                            {
                                NSLog("Cadastro realizado com sucesso");
                                self.dismissViewControllerAnimated(true, completion: nil)
                            } else {
                                var error_msg:NSString
                                if jsonData["error_message"] as? NSString != nil {
                                    error_msg = jsonData["error_message"] as! NSString
                                } else {
                                    error_msg = "Erro desconhecido"
                                }
                                let alertView:UIAlertView = UIAlertView()
                                alertView.title = "Cadastro falhou!"
                                alertView.message = error_msg as String
                                alertView.delegate = self
                                alertView.addButtonWithTitle("OK")
                                alertView.show()
                                
                            }
                            
                        } else {
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Cadastro falhou!"
                            alertView.message = "Não tem Connexão"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        }
                    }  else {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "Cadastro falhou!"
                        alertView.message = "Não tem conexão"
                        if let error = reponseError {
                            alertView.message = (error.localizedDescription)
                        }
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                    
                    self.performSegueWithIdentifier("goto_login", sender: self)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

