//
//  Seq.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 9/29/17.
//  Copyright © 2017 Yuhuan Jiang. All rights reserved.
//

protocol SeqProtocol: IterableProtocol {
    var head: Element? { get }
    var tail: Self { get }
}

extension SeqProtocol {

}
