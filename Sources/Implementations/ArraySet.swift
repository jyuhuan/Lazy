//
//  ArraySet.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 10/1/17.
//

class ArraySet<X: Equatable>: SetProtocol {
    typealias Key = X
    
    var elements: [X]
    
    init(elements: X...) {
        self.elements = elements
    }
    
    func has(key: X) -> Bool {
        return elements.index(of: key) != nil
    }

}
