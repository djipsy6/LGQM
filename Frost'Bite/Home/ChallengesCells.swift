//
//  ChallengesCells.swift
//  Frost'Bite
//
//  Created by Djibril Coly on 4/18/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

class ChallengesCells: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var parentVC = UIViewController()
    var challengesArray : [[String:String]] = []
    let engine = Engine()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return challengesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "challengecell", for: indexPath) as! SingleChallengeCell
        cell.cover.kf.setImage(with: engine.getPlaylistCover(endname: challengesArray[indexPath.row]["cover"]!), placeholder: UIImage(named: "default_challenge"))
        cell.titleLabel.text = challengesArray[indexPath.row]["title"]
        //cell.titleLabel.numberOfLines = 1
        cell.subtitleLabel.text = "\(challengesArray[indexPath.row]["nb_tracks"] ?? "") " + NSLocalizedString("tracks", comment: "")
        cell.infoLabel.text = challengesArray[indexPath.row]["info"]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 260, height: collectionView.bounds.height - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        game_id = challengesArray[indexPath.row]["id"]!
        parentVC.performSegue(withIdentifier: "preview", sender: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
