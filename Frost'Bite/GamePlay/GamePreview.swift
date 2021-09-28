//
//  GamePreview.swift
//  Frost'Bite
//
//  Created by Djibril Coly on 4/18/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

var game_id = ""

class GamePreview: UIViewController {
    
    @IBOutlet weak var pointsLabel: UIButton!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var nbTracks: UIButton!
    @IBOutlet weak var matchLabel: UIButton!
    @IBOutlet weak var seeProfileButtonOutlet: UIButton!
    @IBOutlet weak var matchProgress: UIProgressView!
    
    let engine = Engine()
    var gameArray : [String:String] = [:]
    
    @IBAction func closeNow(_ sender: Any) {
        self.dismiss(animated: true, completion:  {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableView"), object: nil)
            if showAd {
                showAd = false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAd"), object: nil)
            }
        })
    }
        
    @IBAction func playNow(_ sender: Any) {
        if !gameArray.isEmpty {
            self.performSegue(withIdentifier: "gameplay", sender: nil)
        }
    }
    
    @IBAction func seeProfile(_ sender: Any) {
        if gameArray["gamer_id"] == "0" || gameArray["official"] == "1" {
            throwAlert(title: "Profil masqué", message: "Cet utilisateur préfère rester anonyme. Merci d'en choisir un autre.", in: self)
        } else {
            gamer_id = gameArray["gamer_id"]!
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "openPlayer"), object: nil)
            })
        }
    }
    
    @IBAction func share(_ sender: Any) {
        shortenLink(link: "com.lgqm://game?id=" + game_id)  { (shortLink) in
            UIPasteboard.general.string = shortLink
            DispatchQueue.main.async(execute: {
                throwAlert(title: NSLocalizedString("linkToProfileCopied", comment: ""), message: NSLocalizedString("linkToProfileUsage", comment: ""), in: self)
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.getGamePreview), name:NSNotification.Name(rawValue: "refreshMatch"), object: nil)

        getGamePreview()
        seeProfileButtonOutlet.isEnabled = false
        
        if game_id == "" {
            self.dismiss(animated: true, completion: nil)
        }
        
    }

    
    @objc func getGamePreview() {
        
        let querystring = engine.getGameData(game: game_id)
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
                            
                            if let pick = jsonResult as? [String:String] {
                                self.gameArray = pick
                                DispatchQueue.main.async(execute: {
                                    self.updateUI()
                                })
                                
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

    func updateUI() {
        cover.kf.setImage(with: engine.getPlaylistCover(endname: gameArray["cover"]!), placeholder: UIImage(named:"default_cover"))
        titleLabel.text = gameArray["title"]
        subtitleLabel.text = gameArray["subtitle"]
        nbTracks.setTitle(" \(gameArray["nb_tracks"] ?? "") \(NSLocalizedString("tracks", comment: ""))   •", for: .normal)
        matchLabel.setTitle(" \(gameArray["match"] ?? "")% " + NSLocalizedString("matching", comment: ""), for: .normal)
        matchProgress.setProgress((gameArray["match"]! as NSString).floatValue / 100, animated: true)
        seeProfileButtonOutlet.isEnabled = true
        pointsLabel.setTitle(" \(gameArray["points"] ?? "•")" + NSLocalizedString("xp", comment: ""), for: .normal)
    }
    
}
