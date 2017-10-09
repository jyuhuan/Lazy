//
//  OptionalSugars.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 10/8/17.
//

// Swift 4 comiplier crashes on this code.
// See [SR-6090](https://bugs.swift.org/browse/SR-6090)

//extension Optional: Sequence {
//    public func makeIterator() -> OptionalIterator<Wrapped> {
//        return OptionalIterator(self)
//    }
//    
//    public func get() -> Wrapped {
//        return unsafelyUnwrapped
//    }
//}
//
//public class OptionalIterator<T>: IteratorProtocol {
//    let o: Optional<T>
//    
//    init(_ o: Optional<T>) {
//        self.o = o
//    }
//    
//    public func next() -> T? {
//        return o == nil ? nil : o!
//    }
//    
//    public typealias Element = T
//    
//    
//}

