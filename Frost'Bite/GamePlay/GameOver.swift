//
//  GameOver.swift
//  Frost'Bite
//
//  Created by Djibril Coly on 4/18/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

var showAd = false

class GameOver: UIViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var appreciationLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    let engine = Engine()
    
    @IBAction func done(_ sender: Any) {
        //gamer_id = getUserData(scope: "user_id")
        //self.performSegue(withIdentifier: "home", sender: nil)
        if !synched {
            throwAlert(title: NSLocalizedString("syncing", comment: ""), message: NSLocalizedString("syncingPending", comment: ""), in: self)
            if getUserData(scope: "user_id") == "-1" {
                syncGameData(ghost: true)
            } else {
                syncGameData(ghost: false)
            }
        } else {
            self.dismiss(animated: true, completion: {
                showAd = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "exit"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshMatch"), object: nil)
            })
        }
    }
    
    @IBAction func shareLink(_ sender: Any) {
        shortenLink(link: "com.lgqm://game?id=" + game_id)  { (shortLink) in
            UIPasteboard.general.string = shortLink
            DispatchQueue.main.async(execute: {
                throwAlert(title: NSLocalizedString("gameLinkCopied", comment: ""), message: NSLocalizedString("gameLinkUsage", comment: ""), in: self)
            })
        }
    }
    
    var motivation = "win"
    var player = AVPlayer()
    var playerController = AVPlayerViewController()
    var appreciation = ""
    var score = ""
    var coverArtwork = ""
    var gameTitle = ""
    var gameSubtitle = ""
    var game_id = ""
    var songs = ""
    var owner_id = ""
    var synched = false
    var intScore = 0
    var points = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = AVPlayer(url: Bundle.main.url(forResource: motivation, withExtension: "mp4")!)

        playerController.player = player
        playerController.view.frame.size.height = videoView.frame.size.height
        playerController.view.frame.size.width = videoView.frame.size.width

        self.videoView.addSubview(playerController.view)
        playerController.showsPlaybackControls = false
        player.play()
        playTone(sound: motivation)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        appreciationLabel.text = appreciation
        scoreLabel.text = score
        titleLabel.text = gameTitle
        subtitleLabel.text = gameSubtitle
        cover.kf.setImage(with: engine.getPlaylistCover(endname: coverArtwork), placeholder: UIImage(named: "default_cover"))
        
        if getUserData(scope: "user_id") == "-1" {
            syncGameData(ghost: true)
        } else {
            syncGameData(ghost: false)
        }

    }

    @objc func playerItemDidReachEnd (notification: Notification) {
        print("FINISHED")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.player.pause()
        tonePlayer?.pause()
    }
    
    func syncGameData(ghost:Bool) {
        
        var querystring = ""
        
        if ghost {
            querystring = engine.syncGhostGameData(gamer: owner_id, game: game_id, score: String(intScore), songs: songs, points: points)
        } else {
            querystring = engine.syncGameData(gamer: owner_id, game: game_id, score: String(intScore), songs: songs, points: points)
        }
        
        print(querystring)
        
        if let encoded = querystring.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let url = URL(string: encoded)
        {
            let task = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                if error != nil {
                    //print(error!)
                } else {
                    if let urlContent = data {
                        
                        self.synched = true

                        do {
                            let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers)
                            
                            print(jsonResult)
                            if let pick = jsonResult as? [String: String] {
                                
                                
                                switch pick["header"] {
                                case "Synched":
                                    if !ghost {
                                        let userData = ["name": getUserData(scope: "name"), "emailid": getUserData(scope: "emailid"), "user_id": getUserData(scope: "user_id"), "avatar": getUserData(scope: "avatar"), "password": getUserData(scope: "password"), "nb_playlists": getUserData(scope: "nb_playlists"), "score": String(Int(getUserData(scope: "score"))! + self.points), "premium": getUserData(scope: "premium")]
                                        UserDefaults.standard.set(userData, forKey: "userData")
                                    }
                                    print("SYNCHED")
                                default:
                                    print("ERROR")
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
