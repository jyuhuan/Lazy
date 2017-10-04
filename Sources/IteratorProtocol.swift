//
//  Iterator.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 9/29/17.
//  Copyright © 2017 Yuhuan Jiang. All rights reserved.
//

/// An empty iterator which contains no element.
///
/// - Todo: Would be so much better if we could define a dummy iterator as follows
///
///       struct DummyIterator: IteratorProtocol {
///           typealias Element = Never
///           mutating func next() -> Never? {
///               fatalError("Cannot call next on a dummy iterator!")
///           }
///       }
///
///  But this makes Swift 4 compiler crash (see [SR-6045](https://bugs.swift.org/browse/SR-6045)).
///
class EmptyIterator<T>: IteratorProtocol {
    typealias Element = T
    func next() -> T? { return nil }
}


class IndexedIterator<OldIterator: IteratorProtocol>: IteratorProtocol {
    
    typealias Element = (Int, OldIterator.Element)
    
    var oldIter: OldIterator
    var i: Int
    
    init(_ oldIter: OldIterator) {
        self.oldIter = oldIter
        i = -1
    }
    
    func next() -> (Int, OldIterator.Element)? {
        let oldNext = oldIter.next();
        if oldNext == nil { return nil }
        i += 1
        return (i, oldNext!)
    }
    
}


class MappedIterator<OldIterator: IteratorProtocol, NewElement>: IteratorProtocol {
    
    typealias Element = NewElement
    
    var oldIterator: OldIterator
    let f: (OldIterator.Element) -> NewElement
    
    init(_ oldIterator: OldIterator, _ f: @escaping (OldIterator.Element) -> NewElement) {
        self.oldIterator = oldIterator
        self.f = f
    }
    
    func next() -> NewElement? {
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

class FlatMappedIterator<OldIterator: IteratorProtocol, NewIterator: IteratorProtocol>: IteratorProtocol {
    
    typealias Element = NewIterator.Element
    
    var outer: OldIterator
    var inner: AnyIterator<NewIterator.Element>
    
    let f: (OldIterator.Element) -> NewIterator
    
    init(_ oldIterator: OldIterator, _ f: @escaping (OldIterator.Element) -> NewIterator) {
        self.f = f
        self.outer = oldIterator
        self.inner = AnyIterator(EmptyIterator<NewIterator.Element>())
    }
    
    func next() -> NewIterator.Element? {
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


class GroupedConsecutivelyByIterator<Iterator: IteratorProtocol, Key: Equatable & Defaultable>: IteratorProtocol {
    typealias Element = AnyIterable<RandomAccessSeqDefaultIterator<ArraySeq<Iterator.Element>>>
    
    let f: (Iterator.Element) -> Key
    var it: Iterator
    var key: Key
    var g: ArraySeq<Iterator.Element>
    var buf: ArraySeq<Iterator.Element>
    
    init(_ it: Iterator, _ f: @escaping (Iterator.Element) -> Key) {
        self.f = f
        self.it = it
        self.key = Key.defaultValue()
        self.g = ArraySeq<Iterator.Element>.empty()
        self.buf = ArraySeq<Iterator.Element>.empty()
    }
    
    func next() -> Element? {
        while let cur = it.next() {
            let curKey = f(cur)
            if key == curKey || buf.isEmpty {
                buf.append(cur)
                key = curKey
            }
            else {
                g = buf.clone()
                buf.clear()
                buf.append(cur)
                key = curKey
                return AnyIterable(g)
            }
        }
        if (buf.notEmpty) {
            g = buf.clone()
            buf.clear()
            return AnyIterable(g)
        }
        return nil
    }
}

class ZippedIterator<Iterator1: IteratorProtocol, Iterator2: IteratorProtocol>: IteratorProtocol {
    typealias Element = (Iterator1.Element, Iterator2.Element)
    
    var i1: Iterator1
    var i2: Iterator2
    
    init(_ i1: Iterator1, _ i2: Iterator2) {
        self.i1 = i1
        self.i2 = i2
    }
    
    func next() -> (Iterator1.Element, Iterator2.Element)? {
        let e1 = i1.next()
        if e1 == nil { return nil }
        let e2 = i2.next()
        if e2 == nil { return nil }
        return (e1!, e2!)
    }
 }

class ConcatenatedIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var i1: Iterator
    var i2: Iterator
    
    init(_ i1: Iterator, _ i2: Iterator) {
        self.i1 = i1
        self.i2 = i2
    }
    
    func next() -> Iterator.Element? {
        let e1 = i1.next()
        if e1 != nil { return e1 }
        let e2 = i2.next()
        return e2 == nil ? nil : e2
    }
}

