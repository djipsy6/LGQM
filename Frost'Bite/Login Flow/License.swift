//
//  License.swift
//  FrostBite
//
//  Created by Djibril Coly on 4/21/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

class License: UIViewController {
    
    @IBOutlet weak var licenseView: UITextView!
    
    let engine = Engine()
    var loaded = false
    
    @IBAction func acceptEula(_ sender: Any) {
        if !loaded {
            throwAlert(title: NSLocalizedString("waitForEula", comment: ""), message: NSLocalizedString("waitForEulaDesc", comment: ""), in: self)
            return
        }
        if getUserData(scope: "user_id") == "-1" {
            self.performSegue(withIdentifier: "continue", sender: nil)
        } else {
            self.performSegue(withIdentifier: "login", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        licenseView.text =  NSLocalizedString("loadingEula", comment: "")
        fetchLicense()
    }
    
    func fetchLicense() {
        let path = engine.server + "frostbite/license_" + engine.locale + ".rtf"
        if let url = URL(string: path) {
            let task = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                self.loaded = true
                if error != nil {
                    //print(error!)
                } else {
                    if let urlContent = data {
                        do {
                            let contents = try NSAttributedString(data: urlContent, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                            
                            DispatchQueue.main.async(execute: {
                                
                                self.licenseView.attributedText = contents
                                self.licenseView.textColor = .white
                                
                            })
                            
                        } catch {
                            self.licenseView.text = "Oops! Nous n'avons pas pu charger les conditions d'utilisation. Merci de réessayer plus-tard."
                        }
                    }
                    
                }
            }
            task.resume()
        }
    }
                
}

