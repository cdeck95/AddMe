//
//  APIMessageParser .swift
//  LinkUp
//
//  Created by Tom Miller on 10/9/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation
import FCAlertView

class APIMessageParser {
    
    var received: String = ""
    var output: String = ""
    var title: String = ""
    
    init(received: String, parent: UIViewController) {
        self.received = received
        parseMessage(input: received, parent: parent);
    }
    
    func getCode() -> String{
        return output
    }
    
    func getTitle() -> String{
        return title
    }
    
    func parseMessage(input: String, parent: UIViewController) {
            print("=====Parsing the status code=====")
            if let range = input.range(of: "Status Code: ") {
                let strippedInput = input[..<range.lowerBound]
                let num = input.index(input.startIndex, offsetBy: strippedInput.count)
                let str = input[num...]
                var chunks = str.split(separator: " ")
                var code: String = String(chunks[2])
                output = code
                switch(code.dropLast()){
                case "200":
                    title = "Success"
                    break
                case "404":
                    title = "Not found error"
                    let vc : AnyObject! = parent.storyboard!.instantiateViewController(withIdentifier: "Help")
                    parent.show(vc as! UIViewController, sender: vc)
                    break
                default:
                    break
                }
            }
            else {
                print("String not present")
            }
            print("=================================")
        }
}
