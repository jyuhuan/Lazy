//
//  SetProtocol.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 10/1/17.
//

protocol SetProtocol: MapProtocol where Val == Void {
    
//    func interset<ThatSet: SetProtocol, ResultSet: SetProtocol>(that: ThatSet) -> ResultSet
//    func union<ThatSet: SetProtocol, ResultSet: SetProtocol>(that: ThatSet) -> ResultSet
}

extension SetProtocol {
    
    func valueOf(key: Key) -> Void? {
        return nil
    }

    func filtered(by predicate: @escaping (Key) -> Bool) -> FilteredSet<Self> {
        return FilteredSet(self, predicate)
    }
}


struct FilteredSet<SourceSet: SetProtocol>: SetProtocol {
    typealias Key = SourceSet.Key
    
    let sourceSet: SourceSet
    let p: (Key) -> Bool
    
    init(_ sourceSet: SourceSet, _ p: @escaping (Key) -> Bool) {
        self.sourceSet = sourceSet
        self.p = p
    }
    
    func has(key: Key) -> Bool {
        return sourceSet.has(key: key) && p(key)
    }
    
}

