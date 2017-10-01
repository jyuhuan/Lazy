//
//  Iterator.swift
//  Collection
//
//  Created by Yuhuan Jiang on 9/29/17.
//  Copyright © 2017 Yuhuan Jiang. All rights reserved.
//

protocol IterableProtocol {
    associatedtype Element
    associatedtype Iterator: IteratorProtocol where Iterator.Element == Element

    func makeIterator() -> Iterator
}

extension IterableProtocol {

    var indexed: IterableOf<IndexedIterator<Iterator>> {
        get {
            return IterableOf(IndexedIterator(self.makeIterator()))
        }
    }

    func mapped<Target>(by transformation: @escaping (Element) -> Target) -> IterableOf<MappedIterator<Element, Target, Iterator>> {
        return IterableOf(MappedIterator(self.makeIterator(), transformation))
    }

}

struct IterableOf<Iterator: IteratorProtocol>: IterableProtocol {
    typealias Element = Iterator.Element
    var iterator: () -> Iterator
    init(_ iterator: @escaping @autoclosure () -> Iterator) { self.iterator = iterator }
    func makeIterator() -> Iterator { return iterator() }
}

struct SwiftSequenceFromIterable<Iterable: IterableProtocol>: Sequence {
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
    var swiftSequence: SwiftSequenceFromIterable<Self> {
        get {
            return SwiftSequenceFromIterable(self)
        }
    }
}

