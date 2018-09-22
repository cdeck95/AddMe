//
//  EFIntSize.swift
//  LinkUp
//
//  Created by Christopher Deck on 8/29/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//
import Foundation
import UIKit

public class EFIntSize {
    public private(set) var width: Int = 0
    public private(set) var height: Int = 0
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    public func toCGSize() -> CGSize {
        return CGSize(width: self.width, height: self.height)
    }
    
    public func widthCGFloat() -> CGFloat {
        return CGFloat(width)
    }
    
    public func heightCGFloat() -> CGFloat {
        return CGFloat(height)
    }
}
