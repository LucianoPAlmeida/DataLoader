//
//  Array+Utils.swift
//  DataLoader
//
//  Created by Luciano Almeida on 18/02/17.
//  Copyright © 2017 Luciano Almeida. All rights reserved.
//

import Foundation

extension Array where Element : Equatable{
    
    
    
    @discardableResult
    mutating func remove(object: Iterator.Element) -> Iterator.Element?{
        if let idx = self.index(of: object) {
            return self.remove(at: idx)
        }
        return nil
    }
    
    mutating func remove(objects: [Iterator.Element]) {
        for value in objects {
            self.remove(object: value)
        }
    }
}

