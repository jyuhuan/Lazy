//
//  Iterator.swift
//  Collection
//
//  Created by Yuhuan Jiang on 9/29/17.
//  Copyright © 2017 Yuhuan Jiang. All rights reserved.
//

struct EmptyIterator<T>: IteratorProtocol {
    typealias Element = T
    mutating func next() -> T? { fatalError("Cannot call next on an empty iterator!") }
}

/// The iterator in the iterable returned by the property `indexed`
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

/// The iterator in the iterable returned by the method `mapped:by`.
struct MappedIterator<OldIterator: IteratorProtocol, NewElement>: IteratorProtocol {
    
    typealias Element = NewElement
    
    var oldIterator: OldIterator
    let f: (OldIterator.Element) -> NewElement
    
    init(_ oldIterator: OldIterator, _ f: @escaping (OldIterator.Element) -> NewElement) {
        self.oldIterator = oldIterator
        self.f = f
    }
    
    mutating func next() -> NewElement? {
        let old = oldIterator.next()
        return old == nil ? nil : f(old!)
    }
    
}

class FilteredIterator<OldIterator: IteratorProtocol>: IteratorProtocol {
    
    typealias Element = OldIterator.Element
    
    var oldIterator: OldIterator
    let p: (OldIterator.Element) -> Bool
    
    init(_ oldIterator: OldIterator, _ p: @escaping (OldIterator.Element) -> Bool) {
        self.oldIterator = oldIterator
        self.p = p
    }
    
    func next() -> OldIterator.Element? {
        while let old = oldIterator.next() {
            if p(old) {
                return old
            }
        }
        return nil
    }
}

struct FlatMappedIterator<T, U>: IteratorProtocol {
    
    typealias Element = U
    
    var outer: AnyIterator<T>
    var inner: AnyIterator<U>
    
    init(_ sourceIterator: AnyIterator<T>) {
        self.outer = sourceIterator
        self.inner = AnyIterator<U>(EmptyIterator<U>())
    }
    
    mutating func next() -> U? {
        fatalError("???")
    }

}
