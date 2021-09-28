//
//  CustomTabBar.swift
//  Flumeo
//
//  Created by Djibril Coly on 12/24/19.
//  Copyright © 2019 Djibril Coly. All rights reserved.
//

import UIKit
import MarqueeLabel

var mainTabBar : UIViewController?
var currentViewController : UIViewController?

class CustomTabBar: UIViewController {
    
    @IBOutlet weak var tabBar: UIVisualEffectView!
    @IBOutlet weak var tabBarHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomBar: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var buttons : [UIButton]!
    @IBOutlet var labels : [UILabel]!
    
    var discover: UIViewController!
    var timeline: UIViewController!
    var friends: UIViewController!
    var search: UIViewController!
    
    var viewControllers: [UIViewController]!
    var atIndex: Int = 0
    
    @IBAction func didPressTab(_ sender: UIButton) {

        let previousIndex = atIndex
        atIndex = sender.tag
        
        buttons[previousIndex].alpha = 0.4
        buttons[sender.tag].alpha = 1
        
        labels[sender.tag].alpha = 1
        labels[previousIndex].alpha = 0.4

        // POP TO ROOT
        if previousIndex == sender.tag {
            if let navController = self.children.first as? UINavigationController {
                navController.popToRootViewController(animated: true)
            }
        }
        
        let previousVC = viewControllers[previousIndex]
        previousVC.willMove(toParent: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParent()
        
        
        let vc = viewControllers[atIndex]
        currentViewController = vc
        addChild(vc)
        
        vc.view.frame = contentView.bounds
        contentView.addSubview(vc.view)
        
        vc.didMove(toParent: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTabBar = self
        
        for i in 0..<buttons.count {
            buttons[i].isSelected = false
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        discover = (storyboard.instantiateViewController(withIdentifier: "home") as! Home)
        timeline = (storyboard.instantiateViewController(withIdentifier: "timeline") as! Timeline)
        friends = (storyboard.instantiateViewController(withIdentifier: "friends") as! Friends)
        search = (storyboard.instantiateViewController(withIdentifier: "search") as! Search)
        
        viewControllers = [discover, timeline, friends, search]
        
        // Do any additional setup after loading the view.
        buttons[atIndex].alpha = 1.0
        didPressTab(buttons[atIndex])
        
        
        switch UIScreen.main.nativeBounds.height {
        case 1136, 1334, 1920, 20208:
            tabBarHeight.constant -= 28
        default:
            print("NO CHANGES NEEDED")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
