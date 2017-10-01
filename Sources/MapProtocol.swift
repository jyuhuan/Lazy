//
//  MapProtocol.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 10/1/17.
//

protocol MapProtocol {
    associatedtype Key: Equatable
    associatedtype Val
    func has(key: Key) -> Bool
    func valueOf(key: Key) -> Val?
}

extension MapProtocol {
    subscript(key: Key) -> Val? {
        get { return valueOf(key: key)}
    }

    func mapped<TargetVal>(by transformation: @escaping (Val) -> TargetVal) -> MappedMap<Key, Self, TargetVal> {
        return MappedMap(self, transformation)
    }
}

struct MappedMap<Key, SourceMap: MapProtocol, TargetVal>: MapProtocol where SourceMap.Key == Key {
    
    typealias Val = TargetVal
    
    let sourceMap: SourceMap
    let f: (SourceMap.Val) -> TargetVal
    
    init(_ sourceMap: SourceMap, _ f: @escaping (SourceMap.Val) -> TargetVal) {
        self.sourceMap = sourceMap
        self.f = f
    }
    
    func has(key: Key) -> Bool {
        return sourceMap.has(key: key)
    }
    
    func valueOf(key: Key) -> Val? {
        let sourceVal = sourceMap[key]
        return sourceVal == nil ? nil : f(sourceVal!);
    }

}
