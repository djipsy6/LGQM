//
//  CustomAlert.swift
//  Flumeo
//
//  Created by Djibril Coly on 11/5/18.
//  Copyright © 2018 Djibril Coly. All rights reserved.
//

import UIKit

var alertTitleText = ""
var alertDescText = ""

class CustomAlert: UIViewController {

    @IBOutlet weak var alertDesc: UILabel!
    @IBOutlet weak var alertTitle: UILabel!
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertTitle.text = alertTitleText
        alertDesc.text = alertDescText
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
