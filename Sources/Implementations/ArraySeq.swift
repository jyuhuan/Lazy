//
//  ArraySeq.swift
//  SwiftCollection
//
//  Created by Yuhuan Jiang on 9/30/17.
//  Copyright © 2017 Yuhuan Jiang. All rights reserved.
//

final class ArraySeq<X>: RandomAccessSeqProtocol, SeqFactory {

    typealias Element = X
    typealias Iterator = ArraySeqIterator<X>

    func makeIterator() -> ArraySeqIterator<X> {
        return ArraySeqIterator(_elems)
    }
    
    var _elems: Swift.Array<X>
    
    init(elements: Swift.Array<X>) {
        _elems = elements
    }
    
    func elementAt(index: Int) -> X? {
        return _elems[index]
    }
    
    var head: X? {
        get {
            return _elems[0]
        }
    }

    var tail: ArraySeq<X> {
        get {
            return self;
        }
    }
    
    var count: Int {
        get { return _elems.count }
    }
    
    var size: Int {
        get { return count }
    }
    
    /* Conforming to Factory */
    
    typealias In = X
    typealias Out = ArraySeq<X>

    static func newBuilder() -> ArraySeqBuilder<X> {
        return ArraySeqBuilder<X>()
    }

}

struct ArraySeqIterator<X>: IteratorProtocol {
    
    typealias Element = X
    
    var _elems: Swift.Array<X>
    var _idx: Int
    
    init(_ elems: Swift.Array<X>) {
        _elems = elems
        _idx = -1
    }
    
    mutating func next() -> X? {
        _idx += 1
        return _idx < _elems.count ? _elems[_idx] : nil
    }
    
}

class ArraySeqBuilder<X>: Builder {
    
    typealias In = X
    typealias Out = ArraySeq<X>
    
    var _arr: Swift.Array<X>
    
    init() {
        _arr = Swift.Array<X>()
    }
    
    func add(_ input: X) {
        _arr.append(input)
    }
    
    func result() -> ArraySeq<X> {
        return ArraySeq(elements: _arr)
    }

}

