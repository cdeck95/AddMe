//
//  JsonApp.swift
//  AddMe
//
//  Created by Tom Miller on 6/27/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation

//typealias Codable = Decodable & Encodable

struct JsonApp: Decodable {
    let cognitoId: String
    let displayName: String
    let platform: String
    let url: String
}

//let people = [Person]()
func parseJSON(data: Data){
    do {
        let decoder = JSONDecoder()
        self.people = try decoder.decode([Person].self, from: data)
    } catch let error {
        print(error as? Any)
    }
}

