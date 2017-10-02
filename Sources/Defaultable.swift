//
//  Default.swift
//  Lazy
//
//  Created by Yuhuan Jiang on 10/2/17.
//


/// Marks a type as having a default value.
protocol Defaultable {
    
    /// The default value of the type marked.
    static func defaultValue() -> Self
    
}
