//
//  KeyedProtocol.swift
//  SwiftCollection
//
//  Created by Yuhuan Jiang on 9/29/17.
//  Copyright © 2017 Yuhuan Jiang. All rights reserved.
//

protocol KeyedProtocol {
    associatedtype Key
    associatedtype Val
    subscript(key: Key) -> Val { get }
}
