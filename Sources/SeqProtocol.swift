//
//  Seq.swift
//  SwiftCollection
//
//  Created by Yuhuan Jiang on 9/29/17.
//  Copyright © 2017 Yuhuan Jiang. All rights reserved.
//

protocol SeqProtocol: IterableProtocol, MapProtocol where Key == Int, Val == Element {
    func head() -> Element?
    func tail() -> Self
}

extension SeqProtocol {

}
