//
//  FriendsCells.swift
//  Frost'Bite
//
//  Created by Djibril Coly on 4/18/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

class FriendsCells: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var parentVC = UIViewController()
    var friendsArray : [[String:String]] = []
    let engine = Engine()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendcell", for: indexPath) as! SingleFriendCell
        if friendsArray[indexPath.row]["cover"] == "default.png" {
            cell.cover.image = getAvatar(id: friendsArray[indexPath.row]["id"]!)
            cell.cover.backgroundColor = .white
        } else {
            cell.cover.kf.setImage(with: engine.getUserPhoto(endname: friendsArray[indexPath.row]["cover"]!), placeholder: UIImage(systemName: "person.crop.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)))
        }
        cell.titleLabel.text = friendsArray[indexPath.row]["title"]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 114, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        gamer_id = friendsArray[indexPath.row]["id"]!
        parentVC.performSegue(withIdentifier: "player", sender: nil)
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
