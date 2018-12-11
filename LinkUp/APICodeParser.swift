//
//  APICodeParser.swift
//  LinkUp
//
//  Created by Tom Miller on 10/23/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation

class APICodeParser {
    var player: String = ""
    var message: String = ""
    var errorCode: String = ""
    
    init(message: String){
        self.message = message
        findCode()
    }
    
    //**** ACCESSOR METHODS  ****\\
    func getMessage() -> String{
        return message
    }
    
    func getErrorCode() -> String{
        return errorCode
    }
    
    func findCode(){
        let str = message
        let array = str.components(separatedBy: "Status Code:")
        print (array)
        if (array.count > 1){
            let str2 = array[1]
            let array2 = str2.components(separatedBy: ",")
            errorCode = array2[0].trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

