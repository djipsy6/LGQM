//
//  Search.swift
//  Le Grand Quiz Musical
//
//  Created by Djibril Coly on 5/5/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

class Search: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var gamesArray : [[String:String]] = []
    let engine = Engine()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gamesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchcell", for: indexPath) as! SearchCell
        cell.cover.kf.setImage(with: engine.getPlaylistCover(endname: gamesArray[indexPath.row]["cover"]!), placeholder:UIImage(named: "default_cover"))
        cell.titleLabel.text = gamesArray[indexPath.row]["title"]
        cell.subtitleLabel.text = NSLocalizedString("contains", comment: "") + " " + gamesArray[indexPath.row]["nb_tracks"]! + " " + NSLocalizedString("tracks", comment: "")
        cell.infoLabel.text = gamesArray[indexPath.row]["info"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tracks = Int(gamesArray[indexPath.row]["nb_tracks"]!), tracks < 4 {
            throwAlert(title: NSLocalizedString("tooFewTracks", comment: ""), message: NSLocalizedString("atLeastFourTracks", comment: ""), in: self)
            return
        }
        
        game_id = gamesArray[indexPath.row]["id"]!
        launchToDos.append("preview")
        goTab(tab: 0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 60, right: 0)
        
        searchField.delegate = self
        getSearchedGames()
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text!.isEmpty ? NSLocalizedString("search", comment: "") : textField.text
        getSearchedGames()
        return true
    }
    
    func getSearchedGames() {
        
        let querystring = engine.searchGames(search: searchField.text!.replacingOccurrences(of: NSLocalizedString("search", comment: ""), with: ""))
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
                                    self.gamesArray = pick
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
