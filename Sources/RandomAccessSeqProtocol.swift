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
