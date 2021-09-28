//
//  TimelineCell.swift
//  Le Grand Quiz Musical
//
//  Created by Djibril Coly on 5/5/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

class TimelineCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var gameCover: UIImageView!
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var gameInfo: UILabel!
    
    @IBOutlet weak var points: UIButton!
    @IBOutlet weak var score: UIButton!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var nbPlays: UIButton!
    @IBOutlet weak var playButtonOutlet: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
