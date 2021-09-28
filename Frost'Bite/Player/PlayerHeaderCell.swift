//
//  PlayerHeaderCell.swift
//  FrostBite
//
//  Created by Djibril Coly on 4/18/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

class PlayerHeaderCell: UITableViewCell {

    @IBOutlet weak var logoutButtonOutlet: UIButton!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var nbTracksLabel: UIButton!
    @IBOutlet weak var matchLabel: UIButton!
    @IBOutlet weak var nbGamesLabel: UIButton!
    @IBOutlet weak var matchProgress: UIProgressView!
    @IBOutlet weak var playButtonOulet: UIButton!
    @IBOutlet weak var shareButtonOutlet: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var segmentTitleLabel: UILabel!
    @IBOutlet weak var playerContentSegments: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
