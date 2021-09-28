//
//  LeaderBoard.swift
//  FrostBite
//
//  Created by Djibril Coly on 4/21/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

class LeaderBoard: UIViewController {

    @IBOutlet weak var firstLogo: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    
    @IBOutlet weak var secondLogo: UIImageView!
    @IBOutlet weak var secondLabel: UILabel!
    
    @IBOutlet weak var thirdLogo: UIImageView!
    @IBOutlet weak var thirdLabel: UILabel!
    
    let engine = Engine()
    var photos : [String] = []
    var labels : [String] = []
    var ids : [String] = []
    @IBAction func closeNow(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if photos[0] == "default.png" {
            firstLogo.image = getAvatar(id: ids[0])
            firstLogo.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        } else {
            firstLogo.kf.setImage(with: engine.getUserPhoto(endname: photos[0]), placeholder: UIImage(named: "default_user"))
        }
        
        if photos[1] == "default.png" {
            secondLogo.image = getAvatar(id: ids[1])
            secondLogo.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        } else {
            secondLogo.kf.setImage(with: engine.getUserPhoto(endname: photos[1]), placeholder: UIImage(named: "default_user"))
        }
        
        if photos[2] == "default.png" {
            thirdLogo.image = getAvatar(id: ids[2])
            thirdLogo.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        } else {
            thirdLogo.kf.setImage(with: engine.getUserPhoto(endname: photos[2]), placeholder: UIImage(named: "default_user"))
        }
        
        firstLabel.text = labels[0]
        secondLabel.text = labels[1]
        thirdLabel.text = labels[2]
        
        leaderBoardShown = true
        // Do any additional setup after loading the view.
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.10, delay: 0.0, options:[.curveEaseOut], animations: {
            self.view.backgroundColor = .clear
        }, completion:nil)
    }

}
