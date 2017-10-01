//
//  ArraySet.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 10/1/17.
//



///  A map backed by a key array and value array.
/// - Note: Only suitable for maps with very few elements.
class ArrayMap<K: Equatable, V>: MapProtocol {
    typealias Key = K
    typealias Val = V

    var keys: Array<K>
    var vals: Array<V>
    
    init(pairs: (K, V)...) {
        keys = Array<K>()
        vals = Array<V>()
        for (k, v) in pairs {
            keys.append(k)
            vals.append(v)
        }
    }
    
    func has(key: K) -> Bool {
        return keys.contains(key)
    }

    func valueOf(key: Key) -> Val? {
        let idx = keys.index(of: key)
        return idx == nil ? nil : vals[idx!]
    }
}
