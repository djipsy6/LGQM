//
//  Login.swift
//  Frost'Bite
//
//  Created by Djibril Coly on 4/17/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

class Login: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailidField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    let engine = Engine()
    
    @IBAction func logIn(_ sender: Any) {
        if isEmailValid(email: emailidField.text!) {
            if passwordField.text!.count > 0 {
                logUserIn(emailid: emailidField.text!, password: passwordField.text!)
            } else {
                throwAlert(title: "Mot de passe requis", message: "Vous devez saisir votre mot de passe pour vous connecter.", in: self)
            }
        } else {
            throwAlert(title: "Adresse e-mail incorrecte", message: "Vérifiez le format de l'adresse e-mail, il semble incorrect.", in: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailidField.delegate = self
        passwordField.delegate = self
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "theme"))
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return self.view.bounds.width * 0.8
        case 1:
            fallthrough
        case 2:
            return 160
        default:
            return 48
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tableView.contentInsetAdjustmentBehavior = .automatic
        passwordField.isSecureTextEntry = textField == passwordField ? true : false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tableView.contentInsetAdjustmentBehavior = .never
        self.view.endEditing(true)
        if textField == emailidField {
            passwordField.becomeFirstResponder()
        } else {
            // ATTEMPT LOGIN
            logUserIn(emailid: emailidField.text!, password: passwordField.text!)
        }
        return true
    }
    
    func logUserIn(emailid:String, password:String) {
        
        loginButtonOutlet.isEnabled = false
        loginButtonOutlet.setTitle(NSLocalizedString("loginIn", comment: ""), for: .disabled)
        emailidField.isEnabled = false
        passwordField.isEnabled = false
        
        let querystring = engine.logUserIn(password: password, emailid: emailid)
        //print(querystring)
        
        if let encoded = querystring.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let url = URL(string: encoded)
        {
            let task = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                if error != nil {
                    //print(error!)
                } else {
                    if let urlContent = data {
                        do {
                            let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers)
                            
                            print(jsonResult)
                            if let pick = jsonResult as? [String: Any] {
                                
                                
                                switch pick["header"] as? String {
                                case "Successful":
                                    DispatchQueue.main.async(execute: {
                                        let userData = ["name": (pick["fullname"] as! String), "emailid": (pick["emailid"] as! String), "user_id": String(pick["id"] as! Int), "avatar": (pick["avatar"] as! String), "password":password, "nb_playlists": (pick["nb_playlists"] as! String), "score": (pick["score"] as! String), "premium": (pick["premium"] as! String)]
                                        UserDefaults.standard.set(userData, forKey: "userData")
                                        self.performSegue(withIdentifier: "continue", sender: nil)
                                    })
                                case "No Matching":
                                    DispatchQueue.main.async(execute: {
                                        throwAlert(title: NSLocalizedString("noAccount", comment: ""), message: NSLocalizedString("noAccountDesc", comment: ""), in: self )
                                        self.loginButtonOutlet.isEnabled = true
                                        self.emailidField.isEnabled = true
                                        self.passwordField.isEnabled = true
                                    })
                                default:
                                    DispatchQueue.main.async(execute: {
                                        throwAlert(title: NSLocalizedString("problemTitle", comment: ""), message: NSLocalizedString("checkAccount", comment: ""), in: self)
                                        self.loginButtonOutlet.isEnabled = true
                                        self.emailidField.isEnabled = true
                                        self.passwordField.isEnabled = true
                                    })
                                }
                                
                            }
                            
                        } catch {
                            //print("Could not Serialize data")
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
}
