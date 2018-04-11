//
//  Array+Utils.swift
//  DataLoader
//
//  Created by Luciano Almeida on 18/02/17.
//  Copyright © 2017 Luciano Almeida. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    mutating func remove(object: Iterator.Element) {
        self = filter({ $0 != object })
    }
}

