//
//  DataLoader.swift
//  DataLoader
//
//  Created by Luciano Almeida on 01/02/17.
//  Copyright © 2017 Luciano Almeida. All rights reserved.
//


class DataLoader<K: Equatable&Hashable, V>: NSObject {
    typealias Loader = (_ resolve: (_ value: V) -> Void, _ reject: (_ error: Error) -> Void)-> Void

    private var loader: Loader!
    private var memoryCache: Cache<K,V> = Cache<K,V>()
    
    private var dispatchQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    
    init(loader: @escaping Loader) {
        super.init()
        self.loader = loader
    }
    
    func load(key: K, cache: Bool = true, completion : @escaping (_ value: V?, _ error: Error?) -> Void) {
        dispatchQueue.async {
            if let value = self.memoryCache.get(for: key) {
                completion(value, nil)
            }else {
                self.loader!({ (value) in
                    if cache {
                        self.memoryCache.set(value: value, for: key)
                    }
                    completion(value, nil)
                }) { (error) in
                    completion(nil, error)
                }
            }
        }
    }
    
    func load(keys: [K], cache: Bool = true, completion : @escaping (_ values: [V]?, _ error: Error?) -> Void) {
//        let queue = Queue<K>(values: keys)
//        let values : [V] = []
//        dispatchQueue.async {
//            while let key = queue.dequeue() {
//                let semaphore = DispatchSemaphore(value: 0)
//                self.load(key: key, completion: { (value, error) in
//                    if let loadedValue = value {
//                        
//                    }
//                    semaphore.signal()
//                })
//                semaphore.wait()
//            }
//        }

    }
    
    func clear(key: K) {
        self.memoryCache.clear()
    }
}
