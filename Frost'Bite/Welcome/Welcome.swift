//
//  Welcome.swift
//  Frost'Bite
//
//  Created by Djibril Coly on 4/18/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class Welcome: UIViewController {

    @IBOutlet weak var videoView: UIView!
    
    @IBAction func goHome(_ sender: Any) {
        self.performSegue(withIdentifier: "continue", sender: nil)
    }
    
    var player = AVPlayer()
    var playerController = AVPlayerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = AVPlayer(url: Bundle.main.url(forResource: NSLocalizedString("welcomeVideo", comment: ""), withExtension: "mp4")!)

        playerController.player = player
        playerController.view.frame.size.height = videoView.frame.size.height
        playerController.view.frame.size.width = videoView.frame.size.width

        self.videoView.addSubview(playerController.view)
        playerController.showsPlaybackControls = false
        player.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)

    }

    @objc func playerItemDidReachEnd (notification: Notification) {
        print("FINISHED")
        self.performSegue(withIdentifier: "continue", sender: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player.pause()
    }
    
}
