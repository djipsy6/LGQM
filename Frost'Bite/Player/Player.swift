//
//  Player.swift
//  Frost'Bite
//
//  Created by Djibril Coly on 4/18/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

var gamer_id = ""

class Player: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func closeNow(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        
    }
    
    var gamerArray : [String:Any] = [:]
    let segments = ["playlists", "data"]
    var segment = 0
    let engine = Engine()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = gamerArray[segments[segment]] as? [[String:String]] {
            return data.count + 1
        } else {
            if gamerArray["title"] != nil {
                return 1
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            tableView.separatorStyle = .singleLine
            let cell = tableView.dequeueReusableCell(withIdentifier: "playerheadercell", for: indexPath) as! PlayerHeaderCell
            cell.titleLabel.text = gamerArray["title"] as? String ?? ""
            cell.subtitleLabel.text = gamerArray["subtitle"] as? String ?? ""
            cell.pointsLabel.text = " \(gamerArray["points"] as? String ?? "") \(NSLocalizedString("xpPoints", comment: "")) "
            cell.nbTracksLabel.setTitle(" \(gamerArray["nb_favorites"] as? String ?? "•••") \(NSLocalizedString("challengeables", comment: ""))", for: .normal)
            cell.matchLabel.setTitle(" \(gamerArray["match"] as? String ?? "•")% \(NSLocalizedString("onYou", comment: ""))", for: .normal)
            cell.nbGamesLabel.setTitle(" \(gamerArray["nb_games"] as? String ?? "•") \(NSLocalizedString("games", comment: ""))", for: .normal)
            if gamerArray["cover"] as! String == "default.png" {
                cell.cover.image = getAvatar(id: gamerArray["id"] as! String)
                cell.cover.backgroundColor = .white
            } else {
                cell.cover.kf.setImage(with: engine.getUserPhoto(endname: gamerArray["cover"] as! String), placeholder: UIImage(systemName: "person.crop.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)))
            }
            cell.matchProgress.setProgress((gamerArray["match"] as! NSString).floatValue / 100, animated: true)
            cell.playerContentSegments.addTarget(self, action:  #selector(self.segmentedControlValueChanged(_:)), for: .valueChanged)
            cell.segmentTitleLabel.text = (segment == 1) ? NSLocalizedString("lastAchievements", comment: "") : NSLocalizedString("challengeablePlaylists", comment: "")
            if getUserData(scope: "user_id") == gamer_id {
                cell.logoutButtonOutlet.setTitle(NSLocalizedString("logOut", comment: ""), for: .normal)
                cell.logoutButtonOutlet.addTarget(self, action: #selector(self.logOut), for: .touchUpInside)
            } else {
                if gamerArray["is_friend"] as! String == "false" {
                    cell.logoutButtonOutlet.setTitle(NSLocalizedString("add", comment: ""), for: .normal)
                    cell.logoutButtonOutlet.backgroundColor = .link
                } else {
                    cell.logoutButtonOutlet.setTitle(NSLocalizedString("remove", comment: ""), for: .normal)
                }
                cell.logoutButtonOutlet.addTarget(self, action: #selector(self.addRemoveFriend), for: .touchUpInside)
            }
            
            cell.playButtonOulet.addTarget(self, action: #selector(self.openGamePreview), for: .touchUpInside)
            cell.shareButtonOutlet.addTarget(self, action: #selector(self.shareLink), for: .touchUpInside)
            return cell
        default:
            if let data = gamerArray[segments[segment]] as? [[String:String]] {
                let cell = tableView.dequeueReusableCell(withIdentifier: "realisationcell", for: indexPath) as! PlayerGamesCells
                cell.cover.kf.setImage(with: engine.getPlaylistCover(endname: data[indexPath.row - 1]["cover"]!), placeholder:UIImage(named: "default_cover"))
                cell.titleLabel.text = data[indexPath.row - 1]["title"]
                cell.scoreLabel.text = " Score: \(data[indexPath.row - 1]["score"] ?? "•")% - \(data[indexPath.row - 1]["points"] ?? "•") \(NSLocalizedString("xp", comment: "")) "
                cell.ownerLabel.text = NSLocalizedString("by", comment: "") + " \(data[indexPath.row - 1]["owner"] ?? "•")"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "realisationcell", for: indexPath) as! PlayerGamesCells
                return cell
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 552
        default:
            return 126
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            if let data = gamerArray[segments[segment]] as? [[String:String]] {
                DispatchQueue.main.async(execute: {
                    game_id = data[indexPath.row - 1]["game_id"]!
                    self.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "openGame"), object: nil)
                    })
                })
            }
        }
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        segment = sender.selectedSegmentIndex
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        getGamerPreview()
        
        if gamer_id == "0" {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func getGamerPreview() {
        
        let querystring = engine.getGamerData(gamer: gamer_id)
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
                            if let pick = jsonResult as? [String:Any] {
                                self.gamerArray = pick
                                DispatchQueue.main.async(execute: {
                                    self.tableView.reloadData()
                                })
                                
                            } else {
                                print("NO")
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
    
    @objc func addRemoveFriend() {
        
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PlayerHeaderCell
        cell.logoutButtonOutlet.setTitle("PATIENTEZ...", for: .disabled)
        cell.logoutButtonOutlet.isEnabled = false
        
        let querystring = engine.addRemoveFriend(gamer: gamer_id)
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
                                DispatchQueue.main.async(execute: {
                                    cell.logoutButtonOutlet.isEnabled = true
                                    if pick["header"] == "Added" {
                                        cell.logoutButtonOutlet.setTitle(NSLocalizedString("remove", comment: ""), for: .normal)
                                        cell.logoutButtonOutlet.backgroundColor = .red
                                    } else if pick["header"] == "Removed" {
                                        cell.logoutButtonOutlet.setTitle(NSLocalizedString("add", comment: ""), for: .normal)
                                        cell.logoutButtonOutlet.backgroundColor = .link
                                    }
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
    
    @objc func openGamePreview() {
        if let data = gamerArray[segments[segment]] as? [[String:String]] {
            game_id = data[0]["game_id"]!
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "openGame"), object: nil)
            })
        }
    }
    
    @objc func logOut() {
        UserDefaults.standard.set(nil, forKey: "userData")
        UserDefaults.standard.set(nil, forKey: "theme")
        self.performSegue(withIdentifier: "login", sender: nil)
    }
    
    @objc func shareLink() {
        shortenLink(link: "com.lgqm://profile?gamer=" + gamer_id)  { (shortLink) in
            UIPasteboard.general.string = shortLink
            DispatchQueue.main.async(execute: {
                throwAlert(title: NSLocalizedString("gamerLinkCopied", comment: ""), message:NSLocalizedString("gamerLinkUsage", comment: ""), in: self)
            })
        }
    }
    
}
