//
//  Timeline.swift
//  Le Grand Quiz Musical
//
//  Created by Djibril Coly on 5/5/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

class Timeline: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var themeLayer: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var timelineArray: [[String:String]] = []
    let engine = Engine()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelineArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "timelineheadercell", for: indexPath) as! TimelineHeaderCell
            if getUserData(scope: "avatar") == "default.png" || getUserData(scope: "user_id") == "-1" {
                cell.cover.image = getAvatar(id: getUserData(scope: "user_id"))
                cell.cover.backgroundColor = .white
            } else {
                cell.cover.kf.setImage(with: engine.getUserPhoto(endname: getUserData(scope: "avatar")), placeholder: UIImage(systemName: "person.crop.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)))
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            cell.subtitleLabel.text = NSLocalizedString("lastUpdate", comment: "") + " " + formatter.string(from: Date())
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "timelinecell", for: indexPath) as! TimelineCell
            cell.nameLabel.text = timelineArray[indexPath.row - 1]["name"]
            cell.timeLabel.text = timelineArray[indexPath.row - 1]["date"]
            if timelineArray[indexPath.row - 1]["avatar"] == "default.png" {
                cell.avatar.image = getAvatar(id: timelineArray[indexPath.row - 1]["gamer_id"]!)
                cell.avatar.backgroundColor = .white
            } else {
                cell.avatar.kf.setImage(with: engine.getUserPhoto(endname: timelineArray[indexPath.row - 1]["avatar"]!), placeholder: UIImage(systemName: "person.crop.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)))
            }
            
            cell.gameCover.kf.setImage(with: engine.getPlaylistCover(endname: timelineArray[indexPath.row - 1]["cover"]!), placeholder: UIImage(named: "default_challenge"))
            cell.gameTitle.text = timelineArray[indexPath.row - 1]["title"]
            cell.gameInfo.text = timelineArray[indexPath.row - 1]["owner"]
            cell.nbPlays.setTitle(timelineArray[indexPath.row - 1]["nb_games"], for: .normal)
            cell.points.setTitle(" " + timelineArray[indexPath.row - 1]["points"]!, for: .normal)
            cell.score.setTitle(" " + timelineArray[indexPath.row - 1]["score"]!, for: .normal)
            cell.rankLabel.text = timelineArray[indexPath.row - 1]["rank"]
            cell.playButtonOutlet.tag = indexPath.row - 1
            cell.playButtonOutlet.addTarget(self, action: #selector(self.playGame(_:)), for: .touchUpInside)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            getTimelineData()
        } else {
            gamer_id = timelineArray[indexPath.row - 1]["gamer_id"]!
            launchToDos.append("player")
            goTab(tab: 0)
        }
    }
    
    @objc func playGame(_ sender:UIButton) {
        game_id = timelineArray[sender.tag]["game_id"]!
        launchToDos.append("preview")
        goTab(tab: 0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 260 : 252
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        if getUserData(scope: "user_id") == "-1" {
            throwAlert(title: NSLocalizedString("connectPlease", comment: ""), message: NSLocalizedString("connectToTrackFriends", comment: ""), in: self)
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        if let theme = UserDefaults.standard.value(forKey: "theme") as? Int, theme < 7, theme > 0 {
            themeLayer.kf.setImage(with: Bundle.main.url(forResource: "\(theme)", withExtension: "gif"))
        }
        
        getTimelineData()
    }

    func getTimelineData() {
        
        if getUserData(scope: "user_id") == "-1" {
            throwAlert(title: NSLocalizedString("connectPlease", comment: ""), message: NSLocalizedString("connectToTrackFriends", comment: ""), in: self)
            return
        }
        
        let querystring = engine.getTimelineData()
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
                            if let pick = jsonResult as? [[String:String]] {
                                DispatchQueue.main.async(execute: {
                                    self.timelineArray = pick
                                    self.tableView.reloadData()
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
}
