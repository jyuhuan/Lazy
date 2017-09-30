//
//  RandomAccessSeqProtocol.swift
//  SwiftCollection
//
//  Created by Yuhuan Jiang on 9/29/17.
//  Copyright © 2017 Yuhuan Jiang. All rights reserved.
//

protocol RandomAccessSeqProtocol: SeqProtocol, KeyedProtocol where Key == Int, Element == Val {
    func elementAt(index: Int) -> Element
}

extension RandomAccessSeqProtocol {
    subscript(index: Int) -> Element {
        get {
            return elementAt(index: index)
        }
    }
}
