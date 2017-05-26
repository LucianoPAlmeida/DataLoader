//
//  Queue.swift
//  DataLoader
//
//  Created by Luciano Almeida on 02/02/17.
//  Copyright © 2017 Luciano Almeida. All rights reserved.
//

import Foundation

class Queue<T> {
    
    private var queueValues: [T] = []
    
    convenience init(values: [T]) {
        self.init()
        queueValues.append(contentsOf: values)
    }
    
    func dequeue() -> T? {
        return queueValues.isEmpty ? nil : queueValues.removeFirst()
    }
    
}
