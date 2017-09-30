//
//  Iterator.swift
//  Collection
//
//  Created by Yuhuan Jiang on 9/29/17.
//  Copyright © 2017 Yuhuan Jiang. All rights reserved.
//

struct MappedIterator<T, U, TI: IteratorProtocol>: IteratorProtocol where TI.Element == T {
    
    typealias Element = U
    
    var ti: TI
    let f: (T) -> U
    
    init(_ ti: TI, _ f: @escaping (T) -> U) {
        self.ti = ti
        self.f = f
    }
    
    mutating func next() -> U? {
        let source = ti.next()
        return source == nil ? nil : f(source!)
    }
    
}
