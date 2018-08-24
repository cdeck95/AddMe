//
//  ProfileTableViewCell.swift
//  LinkUp
//
//  Created by Christopher Deck on 8/23/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet var NameLabel: UILabel!
    @IBOutlet var profileNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
