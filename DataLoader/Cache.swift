//
//  Cache.swift
//  DataLoader
//
//  Created by Luciano Almeida on 02/02/17.
//  Copyright © 2017 Luciano Almeida. All rights reserved.
//

import Foundation

class Cache<K: Equatable&Hashable, V> {

    
    private var cache : [K: (V,Date)] = [:]
    
    //The cache expiration time for data default is 30 minutes
    var maxAge: TimeInterval = 1800
    var allowsExpiration: Bool = true
    
    convenience init(allowsExpiration: Bool) {
        self.init()
        self.allowsExpiration = allowsExpiration
    }
    
    convenience init(maxAge: TimeInterval) {
        self.init()
        self.maxAge = maxAge
    }
    
    
    func set(value: V, for key: K) {
        cache.updateValue((value,Date(timeIntervalSinceNow: maxAge)), forKey: key)
    }
    
    func get(for key: K) -> V? {
        if allowsExpiration && isCacheValueExpired(for: key) {
            remove(key: key)
            return nil
        }
        return cache[key]?.0
    }
    
    func contains(key: K) -> Bool {
        if allowsExpiration {
            return  cache.keys.contains(key) && !isCacheValueExpired(for: key)
        }
        return cache.keys.contains(key)
    }
    
    func remove(key: K) {
        cache.removeValue(forKey: key)
    }
    
    func clear() {
        cache.removeAll()
    }
    
    private func isCacheValueExpired(for key: K) -> Bool {
        if let expDate = cache[key]?.1 {
            return Date() > expDate
        }
        return false
    }
}
