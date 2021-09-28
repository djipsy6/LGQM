//
//  Friends.swift
//  Le Grand Quiz Musical
//
//  Created by Djibril Coly on 5/5/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

class Friends: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
   
    var friendsArray : [[String:String]] = []
    let engine = Engine()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendscell", for: indexPath) as! FriendsCell
        cell.titleLabel.text = friendsArray[indexPath.row]["name"]
        cell.subtitleLabel.text = friendsArray[indexPath.row]["score"]
        cell.followsBackLabel.isHidden = (friendsArray[indexPath.row]["follows_back"] == "true") ? false : true
        if friendsArray[indexPath.row]["avatar"] == "default.png" {
            cell.avatar.image = getAvatar(id: friendsArray[indexPath.row]["id"]!)
            cell.avatar.backgroundColor = .white
        } else {
            cell.avatar.kf.setImage(with: engine.getUserPhoto(endname: friendsArray[indexPath.row]["avatar"]!), placeholder: UIImage(systemName: "person.crop.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)))
        }
        
        cell.addRemoveButtonOutlet.tag = Int(friendsArray[indexPath.row]["id"]!)!
        
        if friendsArray[indexPath.row]["is_friend"] == "true" {
            cell.addRemoveButtonOutlet.backgroundColor = .red
            cell.addRemoveButtonOutlet.setTitle(NSLocalizedString("remove", comment: ""), for: .normal)
        } else {
            cell.addRemoveButtonOutlet.backgroundColor = .clear
            cell.addRemoveButtonOutlet.setTitle(NSLocalizedString("add", comment: ""), for: .normal)
        }
       
        cell.addRemoveButtonOutlet.tag = indexPath.row
        cell.addRemoveButtonOutlet.addTarget(self, action: #selector(self.addRemoveFriend(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gamer_id = friendsArray[indexPath.row]["id"]!
        launchToDos.append("player")
        goTab(tab: 0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        searchField.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 60, right: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        getFriendsList()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        getFriendsList()
        textField.text = textField.text!.isEmpty ? NSLocalizedString("search", comment: "") : textField.text
        return true
    }
    
    func getFriendsList() {
        
        let querystring = engine.getFriendsList(search: searchField.text!.replacingOccurrences(of: NSLocalizedString("search", comment: ""), with: ""))
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
                        do {
                            let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers)
                            if let pick = jsonResult as? [[String:String]] {
                                DispatchQueue.main.async(execute: {
                                    self.friendsArray = pick
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
    
    @objc func addRemoveFriend(_ sender:UIButton) {
        
        if getUserData(scope: "user_id") == "-1" {
            throwAlert(title: NSLocalizedString("connectPlease", comment: ""), message: NSLocalizedString("connectDesc", comment: ""), in: self)
            return
        }
        
        sender.setTitle(NSLocalizedString("pending", comment: ""), for: .disabled)
        sender.isEnabled = false
        
        let querystring = engine.addRemoveFriend(gamer: friendsArray[sender.tag]["id"]!)
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
                                    sender.isEnabled = true
                                    if pick["header"] == "Added" {
                                        sender.backgroundColor = .red
                                        sender.setTitle(NSLocalizedString("remove", comment: ""), for: .normal)
                                    } else {
                                        sender.backgroundColor = .clear
                                        sender.setTitle(NSLocalizedString("add", comment: ""), for: .normal)
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
}
