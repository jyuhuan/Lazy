//
//  Factory.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 9/30/17.
//


/// A factory that provides various methods to create an object of type `Out`
/// out of elements of type `In`
protocol Factory {
    associatedtype In
    associatedtype Out
    associatedtype NewBuilder: Builder where NewBuilder.In == Self.In, NewBuilder.Out == Self.Out
    
    static func newBuilder() -> NewBuilder
}

extension Factory {

    
    /// Create an empty output.
    ///
    /// - Returns: An empty output.
    static func empty() -> Out {
        return newBuilder().result()
    }
    
    
    /// Create an Output with elements.
    ///
    /// - Parameter elements: The elements out of which the output is to be built.
    /// - Returns: The output built.
    static func of(elements: In...) -> Out {
        var builder = newBuilder()
        for e in elements {
            builder.add(e)
        }
        return builder.result()
    }
    
    
    /// Convert an `Iterable` to an output
    ///
    /// - Parameter iterable: The iterable of inputs, each should be of type `Factory.In`
    /// - Returns: The output
    static func from<Iterable: IterableProtocol>(iterable: Iterable) -> Out where Iterable.Element == In {
        var builder = newBuilder()
        builder.addAll(iterable)
        return builder.result()
    }
    
}
