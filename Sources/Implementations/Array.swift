//
//  Array.swift
//  SwiftCollection
//
//  Created by Yuhuan Jiang on 9/30/17.
//  Copyright © 2017 Yuhuan Jiang. All rights reserved.
//

class Array<X>: RandomAccessSeqProtocol, SeqFactory {
    
    typealias Element = X
    typealias Iterator = ArrayIterator<X>

    func makeIterator() -> ArrayIterator<X> {
        return ArrayIterator(_elems)
    }
    
    var _elems: Swift.Array<X>
    
    init(elements: Swift.Array<X>) {
        _elems = elements
    }
    
    func elementAt(index: Int) -> Array.Element {
        return _elems[index]
    }
    
    func head() -> Array.Element? {
        return _elems[0]
    }
    
    func tail() -> Self {
        return self;
    }
    
    var count: Int {
        get { return _elems.count }
    }
    
    /* Conforming to Factory */
    
    typealias In = X
    typealias Out = Array<X>

    static func newBuilder() -> ArrayBuilder<X> {
        return ArrayBuilder<X>()
    }

}

struct ArrayIterator<X>: IteratorProtocol {
    
    typealias Element = X
    
    var _elems: Swift.Array<X>
    var _idx: Int
    
    init(_ elems: Swift.Array<X>) {
        _elems = elems
        _idx = -1
    }
    
    mutating func next() -> X? {
        return _idx < _elems.count ? _elems[_idx] : nil
    }
    
}

class ArrayBuilder<X>: Builder {
    
    typealias In = X
    typealias Out = Array<X>
    
    var _arr: Swift.Array<X>
    
    init() {
        _arr = Swift.Array<X>()
    }
    
    func add(_ input: X) {
        _arr.append(input)
    }
    
    func result() -> Array<X> {
        return Array(elements: _arr)
    }

}

