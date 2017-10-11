//
//  IteratorWrappers.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 10/10/17.
//

class NonProactiveIterator<Iterator: IteratorProtocol> {
    var it: Iterator
    var nextElem: Iterator.Element?
    var nextElemIsFetched: Bool
    
    init(_ it: Iterator) {
        self.it = it
        nextElemIsFetched = false
        nextElem = nil
    }
    
    var hasNext: Bool {
        get {
            if nextElemIsFetched {
                return true
            }
            else {
                switch it.next() {
                case let .some(next):
                    nextElem = next
                    nextElemIsFetched = true
                    return true
                default:
                    return false
                }
            }
        }
    }
    
    func next() -> Iterator.Element {
        if nextElemIsFetched {
            nextElemIsFetched = false
            return nextElem!
        }
        else {
            return it.next()!
        }
    }
}
