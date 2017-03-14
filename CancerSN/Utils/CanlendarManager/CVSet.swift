//
//  CVSet.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 17/03/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

/**
  *  Deprecated since Swift 1.2.
  *  Instead use native Swift Set<T> collection.
*/

struct CVSet<T: AnyObject>: ExpressibleByNilLiteral {
    // MARK: - Private properties
    fileprivate var storage = [T]()
    
    // MARK: - Public properties
    var count: Int {
        return storage.count
    }
    
    var last: T? {
        return storage.last
    }
    
    // MARK: - Initialization
    init(nilLiteral: ()) { }
    init() { }
    
    // MARK: - Subscript
    subscript(index: Int) -> T? {
        get {
            if index < storage.count {
                return storage[index]
            } else {
                return nil
            }
        }
    }
}

// MARK: - Mutating methods

extension CVSet {
    mutating func addObject(_ object: T) {
        if indexObject(object) == nil {
            storage.append(object)
        }
    }
    
    mutating func removeObject(_ object: T) {
        if let index = indexObject(object) {
            storage.remove(at: index)
        }
    }
    
    mutating func removeAll(_ keepCapacity: Bool) {
        storage.removeAll(keepingCapacity: keepCapacity)
    }
}

// MARK: - Util 

private extension CVSet {
    func indexObject(_ object: T) -> Int? {
        for (index, storageObj) in storage.enumerated() {
            if storageObj === object {
                return index
            }
        }
        
        return nil
    }
}


// MARK: - SequenceType
extension CVSet: Sequence {
    func makeIterator() -> AnyIterator<T> {
        var power = 0
        let nextClosure : () -> T? = {
            power += 1
            //(power < self.count) ? self.storage[power] : nil
            if (power < self.count){
                return self.storage[power]
            }
            else{
                return nil
            }
        }
        return AnyIterator(nextClosure)
    }
}
