//
//  DataLoader.swift
//  DataLoader
//
//  Created by Luciano Almeida on 01/02/17.
//  Copyright © 2017 Luciano Almeida. All rights reserved.
//


class DataLoader<K: Equatable, V, Loader>: NSObject {
    typealias Loader = (_ resolve: (_ value: V) -> Void, _ reject: (_ error: Error) -> Void)-> Void

    private var loader: Loader!
    private var cache: [K: V] = [:]
    
    init(loader: @escaping Loader) {
        super.init()
        self.loader = loader
    }
    
    func load(key: K, cache: Bool = true, completion : (_ value: V?, _ error: Error?) -> Void) {
       
    }
    
    func load(keys: [K], cache: Bool = true, completion : (_ values: [V]?, _ error: Error?) -> Void) {
        
    }
    
    
}
