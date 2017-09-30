//
//  Iterator.swift
//  Collection
//
//  Created by Yuhuan Jiang on 9/29/17.
//  Copyright © 2017 Yuhuan Jiang. All rights reserved.
//

struct MappedIterator<T, U, TI: IteratorProtocol>: IteratorProtocol where TI.Element == T {
    
    typealias Element = U
    
    var ti: TI
    let f: (T) -> U
    
    init(_ ti: TI, _ f: @escaping (T) -> U) {
        self.ti = ti
        self.f = f
    }
    
    mutating func next() -> U? {
        let source = ti.next()
        return source == nil ? nil : f(source!)
    }
    
}

struct IndexedIterator<OldIterator: IteratorProtocol>: IteratorProtocol {
    
    typealias Element = (Int, OldIterator.Element)
    
    var oldIter: OldIterator
    var i: Int
    
    init(_ oldIter: OldIterator) {
        self.oldIter = oldIter
        i = -1
    }
    
    mutating func next() -> (Int, OldIterator.Element)? {
        let oldNext = oldIter.next();
        if oldNext == nil { return nil }
        i += 1
        return (i, oldNext!)
    }
    
}
