//
//  ViewController.swift
//  Frost'Bite
//
//  Created by Djibril Coly on 4/17/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var themeLayer: UIImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var albumWall: UIImageView!
    @IBOutlet weak var regularHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var shortHeaderHeight: NSLayoutConstraint!
        
    let engine = Engine()
    
    @IBAction func createFlumeoAccount(_ sender: Any) {
        self.performSegue(withIdentifier: "noaccount", sender: nil)
    }
    
    @IBAction func loginAccount(_ sender: Any) {
        self.performSegue(withIdentifier: "continue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        updateUI()
        if let theme = UserDefaults.standard.value(forKey: "theme") as? Int, theme < 7, theme > 0 {
            themeLayer.kf.setImage(with: Bundle.main.url(forResource: "\(theme)", withExtension: "gif"))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if getUserData(scope: "user_id") == "-1" {
            self.performSegue(withIdentifier: "home", sender: nil)
        }
        
        if let userData = UserDefaults.standard.value(forKey: "userData") as? [String:String], let emailid = userData["emailid"], let password = userData["password"], emailid != "", password != "" {
            logUserIn(emailid: emailid, password: password)
        } else {
            loadingView.isHidden = true
        }
        
        updateUI()
    }
    
    @objc func updateUI() {
        let screenRatio = self.view.bounds.height/self.view.bounds.width
        if (screenRatio < 2.16) {
            albumWall.removeConstraint(regularHeaderHeight)
            shortHeaderHeight.isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func logUserIn(emailid:String, password:String) {
        
        let querystring = engine.logUserIn(password: password, emailid: emailid)
        //print(querystring)
        
        if let encoded = querystring.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let url = URL(string: encoded)
        {
            let task = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                if error != nil {
                    self.logUserIn(emailid: emailid, password: password)
                } else {
                    if let urlContent = data {
                        do {
                            let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers)
                            
                            //print(jsonResult)
                            if let pick = jsonResult as? [String: Any] {
                                
                                
                                switch pick["header"] as? String {
                                case "Successful":
                                    DispatchQueue.main.async(execute: {
                                        let userData = ["name": (pick["fullname"] as! String), "emailid": (pick["emailid"] as! String), "user_id": String(pick["id"] as! Int), "avatar": (pick["avatar"] as! String), "password":password, "nb_playlists": (pick["nb_playlists"] as! String), "score": (pick["score"] as! String), "premium": (pick["premium"] as! String)]
                                        UserDefaults.standard.set(userData, forKey: "userData")
                                        self.performSegue(withIdentifier: "home", sender: nil)
                                    })
                                case "No Matching":
                                    fallthrough
                                default:
                                    DispatchQueue.main.async(execute: {
                                        throwAlert(title: NSLocalizedString("problemTitle", comment: ""), message: NSLocalizedString("checkAccount", comment: ""), in: self)
                                        self.loadingView.isHidden = true
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

