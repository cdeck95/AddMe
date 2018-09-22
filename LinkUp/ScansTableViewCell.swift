//
//  ScansTableViewCell.swift
//  LinkUp
//
//  Created by Christopher Deck on 8/31/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class ScansTableViewCell: UITableViewCell {

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var profileName: UILabel!
    @IBOutlet var profileDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
