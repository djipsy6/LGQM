//
//  ChooseTheme.swift
//  Le Grand Quiz Musical
//
//  Created by Djibril Coly on 4/26/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

class ChooseTheme: UIViewController {
    
    @IBOutlet weak var themeLayer: UIImageView!
    
    @IBOutlet weak var theme6: UIImageView!
    @IBOutlet weak var theme5: UIImageView!
    @IBOutlet weak var theme4: UIImageView!
    @IBOutlet weak var theme3: UIImageView!
    @IBOutlet weak var theme2: UIImageView!
    @IBOutlet weak var theme1: UIImageView!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    
    var selected : Int = 1
    var themes : [UIButton] = []
    
    @IBAction func finish(_ sender: Any) {
        if selected == -1 {
            throwAlert(title: NSLocalizedString("noTheme", comment: ""), message: NSLocalizedString("noThemeDesc", comment: ""), in: self)
        } else {
            UserDefaults.standard.set(selected, forKey: "theme")
            self.performSegue(withIdentifier: "home", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        themes = [button1, button2, button3, button4, button5, button6]
        
        theme1.kf.setImage(with: Bundle.main.url(forResource: "1", withExtension: "gif"))
        theme2.kf.setImage(with: Bundle.main.url(forResource: "2", withExtension: "gif"))
        theme3.kf.setImage(with: Bundle.main.url(forResource: "3", withExtension: "gif"))
        theme4.kf.setImage(with: Bundle.main.url(forResource: "4", withExtension: "gif"))
        theme5.kf.setImage(with: Bundle.main.url(forResource: "5", withExtension: "gif"))
        theme6.kf.setImage(with: Bundle.main.url(forResource: "6", withExtension: "gif"))
        
        button1.addTarget(self, action: #selector(self.chooseTheme), for: .touchUpInside)
        button2.addTarget(self, action: #selector(self.chooseTheme), for: .touchUpInside)
        button3.addTarget(self, action: #selector(self.chooseTheme), for: .touchUpInside)
        button4.addTarget(self, action: #selector(self.chooseTheme), for: .touchUpInside)
        button5.addTarget(self, action: #selector(self.chooseTheme), for: .touchUpInside)
        button6.addTarget(self, action: #selector(self.chooseTheme), for: .touchUpInside)
        
        if let theme = UserDefaults.standard.value(forKey: "theme") as? Int {
            themes[theme - 1].setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)), for: .normal)
            themes[theme - 1].borderWidth = 3
            themeLayer.kf.setImage(with: Bundle.main.url(forResource: "\(theme)", withExtension: "gif"))
            themes[theme - 1].borderColor = .white
            selected = theme
        } else {
            // SELECT DEFAULT THEME
            themeLayer.kf.setImage(with: Bundle.main.url(forResource: "1", withExtension: "gif"))
            button1.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)), for: .normal)
            button1.borderWidth = 3
            button1.borderColor = .white
        }
        
    }
    
    @objc func chooseTheme(sender:UIButton) {
        if sender.tag > 3 {
            fireNotification(title: NSLocalizedString("animatedTheme", comment: ""), body: NSLocalizedString("animatedThemeDesc", comment: ""), style: .warning)
        }
        selected = sender.tag
        sender.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)), for: .normal)
        sender.borderWidth = 3
        sender.borderColor = .white
        themeLayer.kf.setImage(with: Bundle.main.url(forResource: "\(sender.tag)", withExtension: "gif"))
        unselectOtherThemes()
    }
    
    func unselectOtherThemes() {
        for i in 1...6 {
            if selected != i {
                themes[i - 1].setImage(nil, for: .normal)
                themes[i - 1].borderWidth = 0
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        theme1.image = nil
        theme1.image = nil
        theme1.image = nil
        theme1.image = nil
        theme1.image = nil
    }
    
}
