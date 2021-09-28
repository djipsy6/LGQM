//
//  Home.swift
//  Frost'Bite
//
//  Created by Djibril Coly on 4/18/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit
import Kingfisher
import GoogleMobileAds

var leaderBoardShown = false

class Home: UIViewController, UITableViewDelegate, UITableViewDataSource, GADRewardedAdDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var themeLayer: UIImageView!
    
    let engine = Engine()
    
    var homeArray : [[String:Any]] = []
    var rewardedAd: GADRewardedAd?
    var leaderBoard : [[String]] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "headercell", for: indexPath) as! HomeHeaderCell
            // UIImage(named: "default_user")
            if getUserData(scope: "avatar") == "default.png" || getUserData(scope: "user_id") == "-1" {
                cell.userPhoto.image = getAvatar(id: getUserData(scope: "user_id"))
                cell.userPhoto.backgroundColor = .white
            } else {
                cell.userPhoto.kf.setImage(with: engine.getUserPhoto(endname: getUserData(scope: "avatar")), placeholder: UIImage(systemName: "person.crop.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)))  
            }
            cell.fullnameLabel.text = getUserData(scope: "name")
            cell.emailidLabel.text = getUserData(scope: "emailid")
            cell.scoreLabel.text = " " + getUserData(scope: "score") + " " + NSLocalizedString("xpPoints", comment: "") + " "
            cell.numberOfFavoritesLabel.text = getUserData(scope: "nb_playlists") == "0" || getUserData(scope: "nb_playlists") == "1" ? getUserData(scope: "nb_playlists") + " " + NSLocalizedString("publicPlaylist", comment: "") : getUserData(scope: "nb_playlists") + " " + NSLocalizedString("publicPlaylists", comment: "")

            if getUserData(scope: "user_id") == "-1" {
                cell.numberOfFavoritesLabel.text = NSLocalizedString("noFlumeoAccount", comment: "")
                cell.emailidLabel.text = NSLocalizedString("logIn", comment: "")
                cell.openGamerProfileOutlet.addTarget(self, action: #selector(self.logIn), for: .touchUpInside)
            } else {
                cell.openGamerProfileOutlet.addTarget(self, action: #selector(self.openGamerProfile), for: .touchUpInside)
            }
            
            
            cell.openFlumeoOutlet.addTarget(self, action: #selector(self.openFlumeoProfile), for: .touchUpInside)
            cell.challengeFriends.addTarget(self, action: #selector(self.shareLink), for: .touchUpInside)
            cell.changeThemeButtonOutlet.addTarget(self, action: #selector(self.changeTheme), for: .touchUpInside)
            return cell
        default:
            
            if let type = homeArray[indexPath.row - 1]["type"] as? String {
                if type == "challenges" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "challengecell", for: indexPath) as! ChallengesCells
                    cell.parentVC = self
                    cell.titleLabel.text = homeArray[indexPath.row - 1]["title"] as? String
                    cell.titleLabel.numberOfLines = 1
                    cell.subtitleLabel.text = homeArray[indexPath.row - 1]["subtitle"] as? String
                    if let data = homeArray[indexPath.row - 1]["data"] as? [[String:String]] {
                        cell.challengesArray = data
                        cell.collectionView.reloadData()
                    }
                    cell.collectionView.reloadData()
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "friendscell", for: indexPath) as! FriendsCells
                    cell.parentVC = self
                    cell.titleLabel.text = homeArray[indexPath.row - 1]["title"] as? String
                    cell.titleLabel.numberOfLines = 1
                    cell.subtitleLabel.text = homeArray[indexPath.row - 1]["subtitle"] as? String
                    if let data = homeArray[indexPath.row - 1]["data"] as? [[String:String]] {
                        cell.friendsArray = data
                        cell.collectionView.reloadData()
                        
                        if (cell.subtitleLabel.text == "Ils sont au dessus du game." || cell.subtitleLabel.text == "They rule the game") && !leaderBoardShown {
                            var labels : [String] = []
                            var photos : [String] = []
                            var ids : [String] = []
                            for i in 0..<3 {
                                labels.append(data[i]["title"]!)
                                photos.append(data[i]["cover"]!)
                                ids.append(data[i]["id"]!)
                            }
                            leaderBoard.append(labels)
                            leaderBoard.append(photos)
                            leaderBoard.append(ids)
                            self.performSegue(withIdentifier: "leaderboard", sender: nil)
                        }
                        
                    }
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "friendscell", for: indexPath) as! FriendsCells
                cell.parentVC = self
                cell.collectionView.reloadData()
                return cell
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 190
        default:
            if let type = homeArray[indexPath.row - 1]["type"] as? String {
                if type == "challenges" {
                    return 208 // + 10
                } else {
                    return 218
                }
            } else {
                return 0
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let toDo = launchToDos.first {
            launchToDos.removeFirst()
            self.performSegue(withIdentifier: toDo, sender: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let theme = UserDefaults.standard.value(forKey: "theme") as? Int, theme < 6, theme > 0 {
            themeLayer.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let theme = UserDefaults.standard.value(forKey: "theme") as? Int, theme < 7, theme > 0 {
            themeLayer.kf.setImage(with: Bundle.main.url(forResource: "\(theme)", withExtension: "gif"))
        }

        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)

        //TEST KEY rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-3940256099942544/1712485313")
        rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-7920076176843779/4113633819")
        loadAd()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.openPlayer), name:NSNotification.Name(rawValue: "openPlayer"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.openGame), name:NSNotification.Name(rawValue: "openGame"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTableView), name:NSNotification.Name(rawValue: "reloadTableView"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.showAd), name:NSNotification.Name(rawValue: "showAd"), object: nil)

        if getUserData(scope: "user_id") != "-1" && token != "" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.saveDeviceToken(device_token: token)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getHomeData()
    }
    
    func loadAd() {
        if getUserData(scope: "premium") == "yes" {
            print("NOT ALLOWED TO SHOW ADS")
            return
        }
        rewardedAd?.load(GADRequest()) { error in
            if let error = error {
                print("COULD NOT LOAD AD \(error)")
            } else {
                print("ADD READY")
            }
        }
    }
    
    // Tells the delegate that the user earned a reward.
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        rewardGamerAd(points: "\(reward.amount)") { (response) in
            DispatchQueue.main.async(execute: {
                let userData = ["name": getUserData(scope: "name"), "emailid": getUserData(scope: "emailid"), "user_id": getUserData(scope: "user_id"), "avatar": getUserData(scope: "avatar"), "password": getUserData(scope: "password"), "nb_playlists": getUserData(scope: "nb_playlists"), "score": String(Int(getUserData(scope: "score"))! + reward.amount.intValue), "premium": getUserData(scope: "premium")]
                UserDefaults.standard.set(userData, forKey: "userData")
                self.tableView.reloadData()
                fireNotification(title: "Récompense publicité", body: NSLocalizedString("youReceived", comment: "") + " " + reward.amount.stringValue + " " + NSLocalizedString("xpPoints", comment: ""), style: .success)
            })
        }
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        loadAd()
    }
    
    @objc func logIn() {
        UserDefaults.standard.set(nil, forKey: "userData")
        UserDefaults.standard.set(nil, forKey: "theme")
        self.performSegue(withIdentifier: "login", sender: nil)
    }
    
    @objc func reloadTableView() {
        tableView.reloadData()
    }
    
    @objc func showAd() {
        if self.rewardedAd?.isReady == true {
            self.rewardedAd?.present(fromRootViewController: self, delegate:self)
        }
    }
    
    @objc func openPlayer() {
        self.performSegue(withIdentifier: "player", sender: nil)
    }
    
    @objc func openGame() {
        self.performSegue(withIdentifier: "preview", sender: nil)
    }
    
    @objc func changeTheme() {
        self.performSegue(withIdentifier: "changetheme", sender: nil)
    }
    
    @objc func openGamerProfile() {
        if getUserData(scope: "user_id") == "-1" {
            throwAlert(title: NSLocalizedString("connectPlease", comment: ""), message: NSLocalizedString("freeAccessLimits", comment: ""), in: self)
        }
        gamer_id = getUserData(scope: "user_id")
        self.performSegue(withIdentifier: "player", sender: nil)
    }
    
    @objc func openFlumeoProfile() {
        if UIApplication.shared.canOpenURL(NSURL(string:"flumeo://")! as URL) {
            UIApplication.shared.open(NSURL(string:"flumeo://")! as URL)
        } else {
            let url = URL(string: "https://apps.apple.com/us/app/flumeo/id1446968702")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func shareLink() {
        
        if getUserData(scope: "user_id") == "-1" {
            throwAlert(title: NSLocalizedString("connectPlease", comment: ""), message: NSLocalizedString("accountNeededForChallenges", comment: ""), in: self)
            return
        }
        
        if getUserData(scope: "nb_playlists") == "0" {
            throwAlert(title: NSLocalizedString("noChallengeableList", comment: ""), message: NSLocalizedString("challengeableListsRequired", comment: ""), in: self)
            return
        }
        
        let alertController = UIAlertController(title: NSLocalizedString("shareMyProfile", comment: ""), message: "", preferredStyle: .actionSheet)
        alertController.view.tintColor = .label
       
        let snapchat = UIAlertAction(title: " " + NSLocalizedString("publishOn", comment: "") + " Snapchat", style: .default) { (_) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myAlert = storyboard.instantiateViewController(withIdentifier: "screenshot") as! Screenshot
            myAlert.saveOnly = false
            myAlert.snap = true
            myAlert.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            myAlert.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            self.present(myAlert, animated: true, completion: nil)
        }
        
        let instagram = UIAlertAction(title: " " + NSLocalizedString("publishOn", comment: "") + " Instagram", style: .default) { (_) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myAlert = storyboard.instantiateViewController(withIdentifier: "screenshot") as! Screenshot
            myAlert.saveOnly = false
            myAlert.snap = false
            myAlert.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            myAlert.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            self.present(myAlert, animated: true, completion: nil)
        }
        
        let photos = UIAlertAction(title: " " + NSLocalizedString("saveInPictureRoll", comment: ""), style: .default) { (_) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myAlert = storyboard.instantiateViewController(withIdentifier: "screenshot") as! Screenshot
            myAlert.saveOnly = true
            myAlert.snap = false
            myAlert.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            myAlert.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            self.present(myAlert, animated: true, completion: nil)
        }
        
        let link = UIAlertAction(title: NSLocalizedString("shareLink", comment: ""), style: .default) { (_) in
           shortenLink(link: "com.lgqm://profile?gamer=" + getUserData(scope: "user_id"))  { (shortLink) in
               UIPasteboard.general.string = shortLink
               DispatchQueue.main.async(execute: {
                   throwAlert(title: NSLocalizedString("linkCopied", comment: ""), message: NSLocalizedString("myLinkUsage", comment: ""), in: self)
               })
           }
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { (_) in }
        
        
        snapchat.setValue(UIImage(named: "snapchat")?.withRenderingMode(.alwaysOriginal), forKey: "image")
        instagram.setValue(UIImage(named: "instagram")?.withRenderingMode(.alwaysOriginal), forKey: "image")
        photos.setValue(UIImage(named: "photos")?.withRenderingMode(.alwaysOriginal), forKey: "image")
        link.setValue(UIImage(named: "link")?.withRenderingMode(.alwaysOriginal), forKey: "image")

        
        snapchat.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        instagram.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        photos.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        link.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

        alertController.addAction(snapchat)
        alertController.addAction(instagram)
        alertController.addAction(photos)
        alertController.addAction(link)
        alertController.addAction(cancel)

        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func getHomeData() {
        
        let querystring = engine.getHomeData()
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
                            
                            if let pick = jsonResult as? [[String: Any]] {
                                
                                DispatchQueue.main.async(execute: {
                                    self.homeArray = pick
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
    
    func logUserIn() {
        
        let querystring = engine.logUserIn(password: getUserData(scope: "password"), emailid: getUserData(scope: "emailid"))
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
                            
                            //print(jsonResult)
                            if let pick = jsonResult as? [String: Any] {
                                
                                
                                switch pick["header"] as? String {
                                case "Successful":
                                    DispatchQueue.main.async(execute: {
                                        let userData = ["name": (pick["fullname"] as! String), "emailid": (pick["emailid"] as! String), "user_id": String(pick["id"] as! Int), "avatar": (pick["avatar"] as! String), "password":getUserData(scope: "password"), "nb_playlists": (pick["nb_playlists"] as! String), "score": (pick["score"] as! String), "premium": (pick["premium"] as! String)]
                                        UserDefaults.standard.set(userData, forKey: "userData")
                                        self.tableView.reloadData()
                                    })
                                case "No Matching":
                                    fallthrough
                                default:
                                    DispatchQueue.main.async(execute: {
                                        throwAlert(title: NSLocalizedString("problemTitle", comment: ""), message: NSLocalizedString("checkAccount", comment: ""), in: self)
                                    })
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "leaderboard" {
            let nextVC = segue.destination as! LeaderBoard
            nextVC.labels = leaderBoard[0]
            nextVC.photos = leaderBoard[1]
            nextVC.ids = leaderBoard[2]
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
