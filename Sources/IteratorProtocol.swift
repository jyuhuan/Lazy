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

class InterleavedIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var i1: Iterator
    var i2: Iterator
    var shouldReturnFrom1: Bool
    
    init(_ i1: Iterator, _ i2: Iterator) {
        self.i1 = i1
        self.i2 = i2
        self.shouldReturnFrom1 = true
    }
    
    func next() -> Iterator.Element? {
        if shouldReturnFrom1 {
            shouldReturnFrom1 = false
            return i1.next()
        }
        else {
            shouldReturnFrom1 = true
            return i2.next()
        }
    }
}


class PrependedIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var i: Iterator
    let e: Element
    var isFirst: Bool
    
    init(_ i: Iterator, _ e: Element) {
        self.i = i
        self.e = e
        self.isFirst = true
    }
    
    func next() -> Element? {
        if isFirst {
            isFirst = false
            return e
        }
        else {
            return i.next()
        }
    }
}

class AppendedIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var i: Iterator
    let e: Element
    var isRead: Bool
    
    init(_ i: Iterator, _ e: Element) {
        self.i = i
        self.e = e
        self.isRead = false
    }
    
    func next() -> Element? {
        if isRead { return nil }
        let x: Optional<Iterator.Element> = i.next()
        if x == nil {
            isRead = true
            return e
        }
        else { return x; }
    }
}

class InsertedIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var i: Iterator
    let e: Element
    let idx: Int
    var curIdx: Int
    
    init(_ i: Iterator, _ e: Element, _ idx: Int) {
        self.i = i
        self.e = e
        self.idx = idx
        self.curIdx = -1
    }
    
    func next() -> Element? {
        curIdx += 1
        if curIdx == idx {
            return e
        }
        else { return i.next() }
    }
}

class TailIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var iter: Iterator
    var isFirst: Bool
    
    init(_ i: Iterator) {
        self.iter = i
        self.isFirst = true
    }
    
    func next() -> Element? {
        if isFirst {
            isFirst = false
            let n = iter.next()
            if n == nil { return nil }
            return iter.next()
        }
        return iter.next()
    }
}

class ForeIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var iter: Iterator
    var prefetched: Element?
    
    init(_ iter: Iterator) {
        self.iter = iter
        self.prefetched = self.iter.next()
    }
    
    func next() -> Element? {
        if prefetched == nil {
            return nil
        }
        
        let element = prefetched!
        prefetched = iter.next()
        if prefetched == nil {
            return nil
        }
        return element
    }
}


/// A right-inclusive slicer.
class SliceIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var iter: Iterator
    var l: Int
    var r: Int
    var curIdx: Int
    var isFirst: Bool
    
    init(_ iter: Iterator, _ l: Int, _ r: Int) {
        self.iter = iter
        self.l = l
        self.r = r
        self.curIdx = 0
        self.isFirst = true
    }
    
    func next() -> Element? {
        if isFirst {
            isFirst = false
            while curIdx < l {
                curIdx += 1
                let _ = iter.next()
            }
            return iter.next()
        }
        else {
            curIdx += 1
            return curIdx < r ? iter.next() : nil
        }
    }
}

class TakeFirstIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var iter: Iterator
    var remainingCount: Int
    
    init(_ iter: Iterator, _ n: Int) {
        self.iter = iter
        self.remainingCount = n
    }
    
    func next() -> Element? {
        let n = iter.next()
        if n == nil {
            return nil
        }
        if remainingCount > 0 {
            remainingCount -= 1
            return n
        }
        return nil
    }
}


class TakeToIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var iter: Iterator
    let f: (Element) -> Bool
    var alreadySatisfied: Bool

    init(_ iter: Iterator, _ f: @escaping (Element) -> Bool) {
        self.iter = iter
        self.f = f
        self.alreadySatisfied = false
    }
    
    func next() -> Element? {
        let n = iter.next()
        if alreadySatisfied || n == nil {
            return nil
        }
        if f(n!) {
            alreadySatisfied = true
        }
        return n
    }
}

class TakeWhileIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var iter: Iterator
    let f: (Element) -> Bool
    
    init(_ iter: Iterator, _ f: @escaping (Element) -> Bool) {
        self.iter = iter
        self.f = f
    }

    func next() -> Element? {
        let n = iter.next()
        if n == nil || f(n!) {
            return nil
        }
        return n
    }
}

class DropFirstIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var iter: Iterator
    let n: Int
    var curIdx: Int
    
    init(_ iter: Iterator, _ n: Int) {
        self.iter = iter
        self.n = n
        self.curIdx = 0
    }
    
    func next() -> Element? {
        while curIdx < n && iter.next() != nil {
            curIdx += 1
        }
        return iter.next()
    }
}

class DropToIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var iter: Iterator
    let f: (Element) -> Bool
    
    init(_ iter: Iterator, _ f: @escaping (Element) -> Bool) {
        self.iter = iter
        self.f = f
    }

    func next() -> Element? {
        while let x = iter.next(), !f(x) { }
        return iter.next()
    }
}

class DropWhileIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var iter: Iterator
    let f: (Element) -> Bool
    var alreadySatisfied: Bool
    
    init(_ iter: Iterator, _ f: @escaping (Element) -> Bool) {
        self.iter = iter
        self.f = f
        alreadySatisfied = false
    }

    func next() -> Element? {
        if alreadySatisfied {
            return iter.next()
        }
        else {
            while true {
                let next = iter.next()
                if next == nil {
                    return nil
                }
                if !f(next!) {
                    alreadySatisfied = true
                    return next
                }
            }
        }
    }
}


struct RepeatedIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var makeIterator: () -> Iterator
    var curIter: Iterator
    var n: Int
    
    init(_ makeIterator: @escaping () -> Iterator, _ n: Int) {
        self.makeIterator = makeIterator
        self.n = n
        self.curIter = makeIterator()
    }
    
    mutating func next() -> Element? {
        if n <= 0 {
            return nil
        }
        let nextOpt = curIter.next()
        switch nextOpt {
        case let .some(next):
            return next
        default:
            n -= 1
            if n == 0 {
                return nil
            }
            curIter = makeIterator()
            return curIter.next()
        }
    }
}

struct CycledIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = Iterator.Element
    
    var makeIterator: () -> Iterator
    var curIter: Iterator
    
    init(_ makeIterator: @escaping () -> Iterator) {
        self.makeIterator = makeIterator
        self.curIter = makeIterator()
    }
    
    mutating func next() -> Element? {
        let nextOpt = curIter.next()
        switch nextOpt {
        case let .some(next):
            return next
        default:
            curIter = makeIterator()
            return curIter.next()
        }
    }
}

struct SlidingWindowIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = AnyIterable<RandomAccessSeqDefaultIterator<ArraySeq<Iterator.Element>>>

    var iter: Iterator
    let windowSize: Int
    let stepSize: Int
    
    var window: Array<Any>
    var isFirst: Bool
    
    init(_ iter: Iterator, _ windowSize: Int, _ stepSize: Int) {
        self.iter = iter
        self.windowSize = windowSize
        self.stepSize = stepSize
        
        window = []
        window.reserveCapacity(windowSize)
        isFirst = true
    }
    
    private func wrappedWindow() -> Element {
        // Convert window to ArraySeq
        let result = window.map { (x: Any) -> Iterator.Element in
            x as! Iterator.Element
        }
        return AnyIterable(ArraySeq(elements: result))
    }
    
    mutating func next() -> Element? {
        if isFirst {
            isFirst = false
            var i = 0
            while i < windowSize {
                let n = iter.next()
                if n == nil {
                    return nil
                }
                window.append(n!)
                i += 1
            }
            return wrappedWindow()
        }
        else {
            var newWindow = Array<Any>()
            newWindow.reserveCapacity(windowSize)
            var i = 0
            while i + stepSize < windowSize {
                newWindow.append(window[i + stepSize])
                i += 1
            }
            
            var j = stepSize - windowSize
            while j > 0 {
                let n = iter.next()
                if n == nil {
                    return nil
                }
                j -= 1
            }
            
            while i < windowSize {
                let n = iter.next()
                if n == nil {
                    return nil
                }
                newWindow.append(n!)
                i += 1
            }
            window = newWindow
            return wrappedWindow()
        }
        
        
    }
}

/// Ported from Scala's GroupedIterator
struct GroupedIterator<Iterator: IteratorProtocol>: IteratorProtocol {
    typealias Element = AnyIterable<RandomAccessSeqDefaultIterator<ArraySeq<Iterator.Element>>>
    
    typealias T = Iterator.Element
    
    var iter: NonProactiveIterator<Iterator>
    var buffer: Array<T>
    let size: Int
    let step: Int
    var filled: Bool
    let partial: Bool
    let pad: Optional<() -> T>
    
    init(_ iter: Iterator, _ size: Int, _ step: Int) {
        self.iter = NonProactiveIterator(iter)
        self.buffer = Array<T>()
        self.size = size
        self.step = step
        self.filled = false
        self.partial = true
        self.pad = nil
    }
    
    private mutating func takeDestructively(_ size: Int) -> Array<T> {
        var buf = Array<T>()
        var i = 0
        while i < size && iter.hasNext {
            buf.append(iter.next())
            i += 1
        }
        return buf
    }
    
    private func padding(_ n: Int) -> Array<T> {
        var res = Array<T>()
        res.reserveCapacity(n)
        var i = 0
        while i < n {
            res.append(pad!())
            i += 1
        }
        return res
    }
    
    private func gap() -> Int {
        return max(step - size, 0)
    }
    
    private mutating func go(_ count: Int) -> Bool {
        let prevSize = buffer.count
        func isFirst() -> Bool { return self.buffer.count == 0 }
        
        let xs: Array<T>;
        let res = takeDestructively(count)
        let shortBy = count - res.count
        if shortBy > 0 && pad != nil {
            xs = res + padding(shortBy)
        }
        else {
            xs = res
        }
        
        let len = xs.count
        let incomplete = len < count
        
        func deliver(_ howMany: Int) -> Bool {
            if howMany <= 0 {
                return false
            }
            if !(isFirst() || len > gap()) {
                return false
            }
            
            if !isFirst() {
                var numToRemove = min(step, prevSize)
                while numToRemove > 0 {
                    buffer.remove(at: 0)
                    numToRemove -= 1
                }
            }
            
            let available = isFirst() ? len : min(howMany, len - gap())
            
            buffer.append(contentsOf: xs.suffix(available))
            filled = true
            return true
        }
        
        if xs.isEmpty {
            return false
        }
        
        if partial {
            return deliver(min(len, size))
        }
        
        if incomplete {
            return false
        }
        
        if isFirst() {
            return deliver(len)
        }
        
        return deliver(min(step, size))
    }
    
    mutating func fill() -> Bool {
        if !iter.hasNext {
            return false
        }
        else if buffer.isEmpty {
            return go(size)
        }
        else {
            return go(step)
        }
    }
    
    mutating func _hasNext() -> Bool {
        return filled || fill()
    }
    
    mutating func _next() -> Element {
        if !filled {
            let _ = fill()
        }
        if !filled {
            fatalError()
        }
        filled = false
        return AnyIterable(ArraySeq(elements: buffer))
    }
    
    mutating func next() -> Element? {
        if _hasNext() {
            return _next()
        }
        else {
            return nil
        }
    }
    
}
