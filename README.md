[![Swift 4.0](https://img.shields.io/badge/Swift-4.0-blue.svg)](https://swift.org)
[![Build Status](https://travis-ci.org/jyuhuan/Lazy.svg?branch=master)](https://travis-ci.org/jyuhuan/Lazy)
[![Code Coverage](https://codecov.io/github/jyuhuan/Lazy/coverage.svg?branch=master)](https://codecov.io/github/jyuhuan/Lazy?branch=master)


# Lazy
A library of generic lazy collections for Swift.

## Progress
This is an active project with the following milestones:

### 🚲 The Essentials
`Seq`, `Set`, `Map`

### 🚗 Graph, Tree & Search
`Graph`, `BipartiteGraph`, various types of `Tree`s.  
An abstraction for state-space searching algorithms.

### ✈️ Tables and Relations
`Table`

### 🚀 Algorithms
Common algorithms should be implemented for the data structures, especially searching algorithms, and algorithms on graphs, trees.



## Pending Swift Issues
- [SR-6045: AnyIterator of Never](https://bugs.swift.org/projects/SR/issues/SR-6045) affects the implementation of `DummyIterator`.
- [SR-6090: Extension of the Optional enum](https://bugs.swift.org/projects/SR/issues/SR-6090) affects the implementation of monadic syntactic sugars for optionals.

## Acknowledgement

Lazy is based largely on [poly-collection](https://github.com/ctongfei/poly-collection).
