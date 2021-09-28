//
//  NoAccount.swift
//  FrostBite
//
//  Created by Djibril Coly on 4/21/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

class NoAccount: UIViewController {

    @IBAction func createAccount(_ sender: Any) {
        if UIApplication.shared.canOpenURL(NSURL(string:"flumeo://")! as URL) {
            UIApplication.shared.open(NSURL(string:"flumeo://")! as URL)
        } else {
            let url = URL(string: "https://apps.apple.com/us/app/flumeo/id1446968702")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func playWithNoAccount(_ sender: Any) {
        let userData = ["name": NSLocalizedString("notLoggedIn", comment: ""), "emailid": NSLocalizedString("restrictedAccess", comment: ""), "user_id": "-1", "avatar": "", "password":"", "nb_playlists": "", "score": "", "premium": "no"]
        UserDefaults.standard.set(userData, forKey: "userData")
        self.performSegue(withIdentifier: "continue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
