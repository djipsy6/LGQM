//
//  PlayerGamesCells.swift
//  FrostBite
//
//  Created by Djibril Coly on 4/18/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

class PlayerGamesCells: UITableViewCell {

    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var tryButtonOutlet: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
