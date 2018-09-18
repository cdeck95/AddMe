//
//  Scan.swift
//  LinkUp
//
//  Created by Christopher Deck on 9/3/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation
import UIKit

struct PagedScans: Codable {
    var scanned_profiles:[PagedProfile.Profile]
    
    enum CodingKeys: String, CodingKey {
        case scanned_profiles
    }
}
