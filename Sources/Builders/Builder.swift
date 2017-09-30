//
//  Builder.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 9/30/17.
//

protocol Builder {
    associatedtype In
    associatedtype Out
    
    mutating func add(_ input: In)

    func result() -> Out
}

extension Builder {
    mutating func addAll<Inputs: IterableProtocol>(_ inputs: Inputs) where Inputs.Element == In {
        var iter = inputs.makeIterator()
        while let input = iter.next() { add(input) }
    }
    
    mutating func sizeHint(_ size: Int) {}
}
