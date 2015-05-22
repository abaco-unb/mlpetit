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
        let regex = NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, count(self))) != nil
    }
}

class AccountViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldConfPass: UITextField!
    @IBOutlet weak var labelPicker: UILabel!

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePhoto: UIButton!
    @IBOutlet weak var libraryPhoto: UIButton!
    
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var userName: String = ""
    var imagePicker: UIImagePickerController!
    var gender:String = ""
    var nationality: String = ""
    
    let natData = ["Brésil","France","Belgique","Canadá","Portugal"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
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

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return  natData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return natData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nationality = natData[row]
        labelPicker.text = nationality
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
        //labelUserName.text = gender
    }
    
    /*
        Validar email
    */
    
    
    @IBAction func saveTapped(sender: AnyObject) {
        
        var username: String = textFieldName.text as String
        var email: String = textFieldEmail.text as String
        var password: String = textFieldPassword.text
        var confirmPassword: String = textFieldConfPass.text
        
        
        if ( username.isEmpty ) {
            
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "O nome é obrigatório"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else if ( email.isEmpty ) {
            
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "Campo email obrigatório"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else if (!email.isEmail()) {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "Pr favor, insira um email válido"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else if ( password.isEmpty  || confirmPassword.isEmpty) {
            
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "Campo senha obrigatório"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else if (password != confirmPassword) {
            
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "A senha não confere com a confirmação"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else if ( gender.isEmpty ) {
            
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Erro ao tentar Registrar os Dados!"
            alertView.message = "É necessário escolher o seu gênero"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else if ( nationality.isEmpty ) {
            
            var alertView:UIAlertView = UIAlertView()
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
            let predicate = NSPredicate(format: "name == %@ && email == %@", textFieldName.text, textFieldEmail.text)
            fetchRequest.predicate = predicate
            
            if let fetchResults = contxt.executeFetchRequest(fetchRequest, error: nil) as? [MUser] {
                if (fetchResults.count > 0) {
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Erro ao tentar Registrar os Dados!"
                    alertView.message = "Conta já cadastrada em nosso banco de dados"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                } else {
                    
                    // Preparando a entidade User para a adição de registros
                    let en = NSEntityDescription.entityForName("User", inManagedObjectContext: contxt)
                    
                    //Criando uma nova instância de dados para inserção
                    var newUser = MUser(entity: en!, insertIntoManagedObjectContext: contxt)
                    
                    //Salvando nosso contexto
                    newUser.name = textFieldName.text
                    newUser.email = textFieldEmail.text
                    newUser.password = textFieldPassword.text
                    newUser.gender = gender
                    newUser.nationality = nationality
                    newUser.image = UIImageJPEGRepresentation(imageView.image, 1)
                    println(newUser)
                    contxt.save(nil)
                    
                    var post:NSString = "name=\(username)&mail=\(email)&password=\(password)&gender=\(gender)&nationality=\(nationality)"
                    
                    NSLog("PostData: %@",post);
                    
                    var url:NSURL = NSURL(string: "http://service.maplango.com.br/user")!
                    
                    var postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
                    
                    var postLength:NSString = String( postData.length )
                    
                    var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
                    request.HTTPMethod = "POST"
                    request.HTTPBody = postData
                    request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    request.setValue("application/json", forHTTPHeaderField: "Accept")
                    
                    
                    var reponseError: NSError?
                    var response: NSURLResponse?
                    
                    var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
                    
                    println(urlData);
                    
                    if ( urlData != nil ) {
                        let res = response as! NSHTTPURLResponse!;
                        
                        NSLog("Response code: %ld", res.statusCode);
                        
                        if (res.statusCode >= 200 && res.statusCode < 300)
                        {
                            var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                            
                            NSLog("Response ==> %@", responseData);
                            
                            var error: NSError?
                            
                            let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                            
                            var success: String = jsonData.valueForKey("id") as! String
                            
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
                                var alertView:UIAlertView = UIAlertView()
                                alertView.title = "Cadastro falhou!"
                                alertView.message = error_msg as String
                                alertView.delegate = self
                                alertView.addButtonWithTitle("OK")
                                alertView.show()
                                
                            }
                            
                        } else {
                            var alertView:UIAlertView = UIAlertView()
                            alertView.title = "Cadastro falhou!"
                            alertView.message = "Não tem Connexão"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        }
                    }  else {
                        var alertView:UIAlertView = UIAlertView()
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

