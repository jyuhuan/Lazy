//
//  SetProtocol.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 10/1/17.
//


protocol SetProtocol {
    associatedtype Element
    func has(_ element: Element) -> Bool
}

extension SetProtocol {
    func hasNot(_ element: Element) -> Bool {
        return !has(element)
    }
    
    func filtered(by predicate: @escaping (Element) -> Bool) -> FilteredSet<Self> {
        return FilteredSet(self, predicate)
    }
}


struct FilteredSet<SourceSet: SetProtocol>: SetProtocol {
    typealias Element = SourceSet.Element
    
    let sourceSet: SourceSet
    let p: (Element) -> Bool
    
    init(_ sourceSet: SourceSet, _ p: @escaping (Element) -> Bool) {
        self.sourceSet = sourceSet
        self.p = p
    }
    
    func has(_ element: Element) -> Bool {
        return sourceSet.has(element) && p(element)
    }
    
}

