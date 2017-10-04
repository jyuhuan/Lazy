//
//  Iterator.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 9/29/17.
//  Copyright © 2017 Yuhuan Jiang. All rights reserved.
//


/// The base protocol for all Lazy collection that provides an iterator.
///
/// As for Swift 4, the `for-in` syntax is only supported on `Sqeuence` objects.
/// However, by definition an object that comforms to `IterableProtocol` is not a sequence.
/// To iterate through a Lazy iterable, there are two ways:
///
/// **Using a While Loop**
///
///     let xs =  // some iterable
///     let iterator = xs.makeIterator()
///     while let x = iterator.next() {
///         // do something with x
///     }
///
/// **Using `swiftSequence`**
///
///     let xs =  // some iterable
///     for x in xs.swiftSequence {
///         // do something with x
///     }
///
/// This cumbersome notation will be abandoned when Swift provides more friendly `for-in` syntax support.
protocol IterableProtocol {
    
    /// The type of the elements in the collection.
    associatedtype Element
    
    /// The iterator exposed by this collection.
    associatedtype Iterator: IteratorProtocol where Iterator.Element == Element

    /// Creates a new iterator that iterates through this collection.
    func makeIterator() -> Iterator
}



// MARK: - Computed properties
extension IterableProtocol {
    var size: Int {
        get {
            var iter = makeIterator()
            var result = 0
            while iter.next() != nil {
                result += 1
            }
            return result
        }
    }
}


// MARK: - Higher-order functions
extension IterableProtocol {
    
    func mapped<NewElement>(by transformation: @escaping (Element) -> NewElement) -> MappedIterable<Self, NewElement> {
        return MappedIterable(self, transformation)
    }
    
    func map<NewElement>(_ f: @escaping (Element) -> NewElement) -> MappedIterable<Self, NewElement> {
        return mapped(by: f)
    }
    
    func flatMapped<NewIterable: IterableProtocol>(by transforamtion: @escaping (Element) -> NewIterable) -> FlatMappedIterable<Self, NewIterable> {
        return FlatMappedIterable(self, transforamtion)
    }
    
    func flatMap<NewIterable: IterableProtocol>(_ transforamtion: @escaping (Element) -> NewIterable) -> FlatMappedIterable<Self, NewIterable> {
        return flatMapped(by: transforamtion)
    }

    func filtered(by predicate: @escaping (Element) -> Bool) -> FilteredIterable<Self> {
        return FilteredIterable(self, predicate)
    }
    
    func filter(_ p: @escaping (Element) -> Bool) -> FilteredIterable<Self> {
        return filtered(by: p)
    }
    
    func filtered(notBy predicate: @escaping (Element) -> Bool) -> FilteredIterable<Self> {
        return filtered(by: {e in !predicate(e)})
    }
    
    func filterNot(_ p: @escaping (Element) -> Bool) -> FilteredIterable<Self> {
        return filtered(notBy: p)
    }
    
    func groupedConsecutively<Key: Equatable>(by: @escaping (Element) -> Key) -> GroupedConsecutivelyByIterable<Self, Key> {
        return GroupedConsecutivelyByIterable(self, by)
    }
    
}



// Convenient transformations
extension IterableProtocol {
    
    var indexed: IndexedIterable<Self> {
        get { return IndexedIterable(self) }
    }
    
}


// MARK: - Interaction with Other Iterables
extension IterableProtocol {
    
    func zipped<That: IterableProtocol>(with that: That) -> ZippedIterable<Self, That> {
        return ZippedIterable(self, that)
    }
    
    func zip<That: IterableProtocol>(_ that: That) -> ZippedIterable<Self, That> {
        return zipped(with: that)
    }
    
    func concatenated(with that: Self) -> ConcatenatedIterable<Self> {
        return ConcatenatedIterable(self, that)
    }
    
    func concatenate(_ that: Self) -> ConcatenatedIterable<Self> {
        return concatenated(with: that)
    }
    
}

// Conversions
extension IterableProtocol {
    
    /// Converts this iterable to any collection that is also a factory.
    ///
    ///     let xs: ArraySeq.of(elements: "a", "a", "b")
    ///     let ys = xs.to(ArraySet.newBuilder)  // ys will be {"a", "b"}
    ///
    /// - Parameter newBuilder: A function to generate a new builder for the desired collection type.
    /// - Returns: A collection of the desired type which contains elements from this iterable.
    ///
    /// - Todo: Would be so much better if this could be defined as
    ///
    ///       func to<F: Factory>() -> F.Out where F.In == Self.Element {
    ///           var builder = F.newBuilder()
    ///           var iterator = self.makeIterator()
    ///           while let element = iterator.next() {
    ///               builder.add(element)
    ///           }
    ///           return buidler.result()
    ///       }
    ///
    ///   Alas, Swift 4 compiler complains:
    ///   `Generic parameter 'F' is not used in function signature`.
    func to<B: Builder>(_ newBuilder: @autoclosure () -> B) -> B.Out where B.In == Self.Element {
        var builder = newBuilder()
        var iterator = self.makeIterator()
        while let element = iterator.next() {
            builder.add(element)
        }
        return builder.result()
    }
    
    
    /// Converts this iterable to Swift's `Array`
    ///
    /// - Returns: An array which contains all the elements in this iterable.
    ///            The elements will appear in the order of `next()`
    func toArray() -> [Element] {
        var arr = Array<Element>()
        var iterator = self.makeIterator()
        while let element = iterator.next() {
            arr.append(element)
        }
        return arr
    }
}


class IterableOf<Iterator: IteratorProtocol>: IterableProtocol {
    typealias Element = Iterator.Element
    var iterator: () -> Iterator
    init(_ iterator: @escaping @autoclosure () -> Iterator) { self.iterator = iterator }
    func makeIterator() -> Iterator { return iterator() }
}

// Result types

class IndexedIterable<OldIterable: IterableProtocol>: IterableProtocol {
    typealias Element = (Int, OldIterable.Element)
    typealias Iterator = IndexedIterator<OldIterable.Iterator>

    let oldIterable: OldIterable
    init(_ oldIterable: OldIterable) {
        self.oldIterable = oldIterable
    }
    func makeIterator() -> Iterator {
        return IndexedIterator(oldIterable.makeIterator())
    }
}

class MappedIterable<OldIterable: IterableProtocol, NewElement>: IterableProtocol {
    typealias Element = NewElement
    typealias Iterator = MappedIterator<OldIterable.Iterator, NewElement>
    
    var oldIterable: OldIterable
    let f: (OldIterable.Element) -> NewElement

    init(_ oldIterable: OldIterable, _ f: @escaping (OldIterable.Element) -> NewElement) {
        self.oldIterable = oldIterable
        self.f = f
    }
    
    func makeIterator() -> MappedIterator<OldIterable.Iterator, NewElement> {
        return MappedIterator<OldIterable.Iterator, NewElement>(oldIterable.makeIterator(), f)
    }
}

class FilteredIterable<OldIterable: IterableProtocol>: IterableProtocol {
    typealias Element = OldIterable.Element
    typealias Iterator = FilteredIterator<OldIterable.Iterator>
    
    let oldIterable: OldIterable
    let p: (OldIterable.Element) -> Bool
    init(_ oldIterable: OldIterable, _ p: @escaping (OldIterable.Element) -> Bool) {
        self.oldIterable = oldIterable
        self.p = p
    }
    
    func makeIterator() -> FilteredIterator<OldIterable.Iterator> {
        return FilteredIterator(oldIterable.makeIterator(), p)
    }
}

class FlatMappedIterable<OldIterable: IterableProtocol, NewIterable: IterableProtocol>: IterableProtocol {
    typealias Element = NewIterable.Element
    typealias Iterator = FlatMappedIterator<OldIterable.Iterator, NewIterable.Iterator>
    
    let oldIterable: OldIterable
    let f: (OldIterable.Element) -> NewIterable
    
    init(_ oldIterable: OldIterable, _ f: @escaping (OldIterable.Element) -> NewIterable) {
        self.oldIterable = oldIterable
        self.f = f
    }
    
    func makeIterator() -> FlatMappedIterator<OldIterable.Iterator, NewIterable.Iterator> {
        return FlatMappedIterator(oldIterable.makeIterator()){ e in self.f(e).makeIterator() }
    }
}

class GroupedConsecutivelyByIterable<Iterable: IterableProtocol, Key: Equatable & Defaultable>: IterableProtocol {
    typealias Element = GroupedConsecutivelyByIterator<Iterable.Iterator, Key>.Element
    
    typealias Iterator = GroupedConsecutivelyByIterator<Iterable.Iterator, Key>
    

    let f: (Iterable.Element) -> Key
    let iterable: Iterable

    init(_ iterable: Iterable, _ f: @escaping (Iterable.Element) -> Key) {
        self.f = f
        self.iterable = iterable
    }
    
    func makeIterator() -> GroupedConsecutivelyByIterator<Iterable.Iterator, Key> {
        return GroupedConsecutivelyByIterator(iterable.makeIterator(), f)
    }

}

class ReversedIterable<OldIterable: IterableProtocol>/* : IterableProtocol */ {
}

class ZippedIterable<Iterable1: IterableProtocol, Iterable2: IterableProtocol>: IterableProtocol {
    typealias Element = (Iterable1.Element, Iterable2.Element)
    typealias Iterator = ZippedIterator<Iterable1.Iterator, Iterable2.Iterator>
    
    let i1: Iterable1
    let i2: Iterable2
    
    init(_ i1: Iterable1, _ i2: Iterable2) {
        self.i1 = i1
        self.i2 = i2
    }
    
    func makeIterator() -> ZippedIterator<Iterable1.Iterator, Iterable2.Iterator> {
        return ZippedIterator(i1.makeIterator(), i2.makeIterator())
    }
}

class ConcatenatedIterable<Iterable: IterableProtocol>: IterableProtocol {
    typealias Element = Iterable.Element
    typealias Iterator = ConcatenatedIterator<Iterable.Iterator>
    
    let i1: Iterable
    let i2: Iterable
    
    init(_ i1: Iterable, _ i2: Iterable) {
        self.i1 = i1
        self.i2 = i2
    }
    
    func makeIterator() -> ConcatenatedIterator<Iterable.Iterator> {
        return ConcatenatedIterator(i1.makeIterator(), i2.makeIterator())
    }
}

// Conversion from Lazy iterables to Swift Sequences, so that the for-in syntax can be used.

class SwiftSequenceFromIterable<Iterable: IterableProtocol>: Sequence {
    typealias Element = Iterable.Element
    typealias Iterator = Iterable.Iterator

    var iterable: Iterable

    init(_ iterable: Iterable) {
        self.iterable = iterable
    }

    func makeIterator() -> Iterator {
        return iterable.makeIterator()
    }
}

extension IterableProtocol {
    /// Disguises the iterable as Swift's `Sequence` so that the `for-in` syntax can be used.
    ///
    ///     let xs = ArraySeq.of(1, 2, 3)
    ///     for x in xs.swiftSequence {
    ///         print(x)
    ///     }
    ///
    var swiftSequence: SwiftSequenceFromIterable<Self> {
        get {
            return SwiftSequenceFromIterable(self)
        }
    }
}


/// A type-erased iterable. The element type is obtained from the iterator type `I`.
class AnyIterable<I: IteratorProtocol>: IterableProtocol {
    typealias Element = I.Element
    typealias Iterator = I
    
    var makeIteratorImpl: () -> Iterator
    
    init<Iterable: IterableProtocol>(_ iterable: Iterable) where Iterable.Iterator == I {
        let iterableCopy = iterable
        self.makeIteratorImpl = { iterableCopy.makeIterator() }
    }
    
    func makeIterator() -> Iterator {
        return makeIteratorImpl()
    }
}


// Operators
infix operator ++
infix operator ⛙

extension IterableProtocol {
    static func ++ (this: Self, that: Self) -> ConcatenatedIterable<Self> {
        return this.concatenated(with: that)
    }
    static func ⛙ <That: IterableProtocol> (this: Self, that: That) -> ZippedIterable<Self, That> {
        return this.zipped(with: that)
    }
}

