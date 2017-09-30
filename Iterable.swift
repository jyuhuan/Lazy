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
    func mapped<Target>(by transformation: @escaping (Element) -> Target) -> MappedIterator<Element, Target, Iterator> {
        return MappedIterator(self.makeIterator(), transformation)
    }
}
