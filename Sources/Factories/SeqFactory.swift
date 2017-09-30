//
//  SeqFactory.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 9/30/17.
//

protocol SeqFactory: Factory where Out: SeqProtocol, Out.Element == In { }

extension SeqFactory {
    static func fill(_ n: Int, _ f: (Int) -> In) -> Out {
        var builder = newBuilder()
        builder.sizeHint(n)
        var i = 0;
        while i < n {
            builder.add(f(i))
            i += 1
        }
        return builder.result()
    }
}
