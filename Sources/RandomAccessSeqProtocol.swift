//
//  RandomAccessSeqProtocol.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 9/29/17.
//  Copyright © 2017 Yuhuan Jiang. All rights reserved.
//

protocol RandomAccessSeqProtocol: SeqProtocol {
    var size: Int { get }
    func elementAt(index: Int) -> Element?
}

extension RandomAccessSeqProtocol {
    
    func makeIterator() -> RandomAccessSeqDefaultIterator<Self> {
        return RandomAccessSeqDefaultIterator(self)
    }
    
    func mapped<NewElement>(by transformation: @escaping (Element) -> NewElement) -> MappedRandomAccessSeq<Self, NewElement> {
        return MappedRandomAccessSeq(self, transformation)
    }

    var head: Element? {
        get {
            return elementAt(index: 0)
        }
    }
    
    var tail: Self {
        get {
            fatalError("???")
        }
    }

    func valueOf(key: Int) -> Element? {
        return elementAt(index: key)
    }
    
    subscript(index: Int) -> Element? {
        get {
            return elementAt(index: index)
        }
    }
    
    func has(key: Int) -> Bool {
        return 0 <= key && key < size
    }
}

final class MappedRandomAccessSeq<OldRandomAccessSeq: RandomAccessSeqProtocol, NewElement>: RandomAccessSeqProtocol {
    
    typealias Element = NewElement
    typealias Iterator = RandomAccessSeqDefaultIterator<MappedRandomAccessSeq>
    
    let oldRandomAccessSeq: OldRandomAccessSeq
    let f: (OldRandomAccessSeq.Element) -> NewElement
    
    init(_ oldRandomAccessSeq: OldRandomAccessSeq, _ f: @escaping (OldRandomAccessSeq.Element) -> NewElement) {
        self.oldRandomAccessSeq = oldRandomAccessSeq
        self.f = f
    }
    
    var size: Int {
        get { return oldRandomAccessSeq.size }
    }
    
    func elementAt(index: Int) -> NewElement? {
        let old = oldRandomAccessSeq.elementAt(index: index)
        return old == nil ? nil : f(old!)
    }
    
}


/// The default iterator used by all classes that conform to `RandomAccessSeqProtocol`.
final class RandomAccessSeqDefaultIterator<RandomAccessSeq: RandomAccessSeqProtocol>: IteratorProtocol {
    let randomAccessSeq: RandomAccessSeq
    var curIdx: Int
    
    init(_ randomAccessSeq: RandomAccessSeq) {
        self.randomAccessSeq = randomAccessSeq
        self.curIdx = 0
    }
    
    func next() -> RandomAccessSeq.Element? {
        if curIdx < randomAccessSeq.size {
            let cur = randomAccessSeq.elementAt(index: curIdx)
            curIdx += 1
            return cur
        }
        else { return nil }
    }
}
