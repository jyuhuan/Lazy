//
//  Range.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 9/30/17.
//  Copyright © 2017 Yuhuan Jiang. All rights reserved.
//

struct RangeIterator: IteratorProtocol {
    let min: Int
    let max: Int
    var cur: Int
    
    init(min: Int, max: Int) {
        self.min = min
        self.max = max
        self.cur = min
    }
    
    mutating func next() -> Int? {
        if (cur < max) {
            let old = cur;
            cur += 1;
            return old;
        }
        else {
            return nil;
        }
    }
    
    typealias Element = Int
    
}

class Range: IterableProtocol {
    typealias Element = Int
    typealias Iterator = RangeIterator
    
    let min: Int
    let max: Int
    
    init(min: Int, max: Int) {
        self.min = min
        self.max = max
    }
    
    func makeIterator() -> RangeIterator {
        return RangeIterator(min: min, max: max)
    }
    
}
