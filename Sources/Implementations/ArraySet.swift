//
//  ArraySet.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 10/1/17.
//

class ArraySet<X: Equatable>: SetProtocol {    
    typealias Element = X
    
    var elements: [X]
    
    init(elements: X...) {
        self.elements = elements
    }
    
    func has(_ element: X) -> Bool {
        return elements.index(of: element) != nil
    }

}
