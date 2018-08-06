//
//  CollectionViewCell.swift
//  AddMe
//
//  Created by Christopher Deck on 2/27/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet var appImage: UIImageView!
    var appLabel: String!
    @IBOutlet weak var appName: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // ...
    }
    
    func displayContent(title: String){
       //self.appImage.image = image.image
        self.appName.text = title
    }
    //image: UIImageView, 
}

