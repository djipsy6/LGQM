//
//  FriendsCell.swift
//  Le Grand Quiz Musical
//
//  Created by Djibril Coly on 5/5/20.
//  Copyright © 2020 NewAfricaTechnology. All rights reserved.
//

import UIKit

class FriendsCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var followsBackLabel: UILabel!
    @IBOutlet weak var addRemoveButtonOutlet: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
