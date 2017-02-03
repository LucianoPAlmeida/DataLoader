//
//  Cache.swift
//  DataLoader
//
//  Created by Luciano Almeida on 02/02/17.
//  Copyright © 2017 Luciano Almeida. All rights reserved.
//

import Foundation

class Cache<K: Equatable&Hashable, V> {

    
    private var cache : [K: V] = [:]
    
    
    func set(value: V, for key: K) {
        cache.updateValue(value, forKey: key)
    }
    
    func get(for key: K) -> V? {
        return cache[key]
    }
    
    func remove(key: K) {
        cache.removeValue(forKey: key)
    }
    
    func clear() {
        cache.removeAll()
    }
}
