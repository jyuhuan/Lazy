 //
//  Iterator.swift
//  Collection
//
//  Created by Yuhuan Jiang on 9/29/17.
//  Copyright © 2017 Yuhuan Jiang. All rights reserved.
//


/// Would be so much better if this is defined as
///
///     struct EmptyIterator: IteratorProtocol {
///         typealias Element = Never
///         mutating func next() -> Never? { fatalError("Cannot call next on an empty iterator!") }
///     }
///
struct EmptyIterator<T>: IteratorProtocol {
    typealias Element = T
    mutating func next() -> T? { return nil }
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

struct FlatMappedIterator<OldIterator: IteratorProtocol, NewIterator: IteratorProtocol>: IteratorProtocol {
    
    typealias Element = NewIterator.Element
    
    var outer: OldIterator
    var inner: AnyIterator<NewIterator.Element>
    
    let f: (OldIterator.Element) -> NewIterator
    
    init(_ oldIterator: OldIterator, _ f: @escaping (OldIterator.Element) -> NewIterator) {
        self.f = f
        self.outer = oldIterator
        self.inner = AnyIterator(EmptyIterator<NewIterator.Element>())
    }
    
    mutating func next() -> NewIterator.Element? {
        let innerElement = inner.next()
        if innerElement != nil {
            return innerElement
        }
        else {
            while let outerElement = outer.next() {
                inner = AnyIterator(f(outerElement))
                let newInnerElement = inner.next()
                if newInnerElement != nil { return newInnerElement }
            }
            return nil
        }
    }

}
