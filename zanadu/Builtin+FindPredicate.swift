//
//  Builtin+FindPredicate.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/10/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/// Find the index of the first element of a sequence that satisfies a predicate
///
/// - parameter sequence: A sequence to be searched
/// - parameter predicate: A function applied to each element in turn until it returns true
///
/// - returns: Zero-based index of first element that satisfies the predicate, or nil if no such element was found
public func find<S: Sequence>(_ sequence: S, predicate: (S.Iterator.Element) -> Bool) -> Int? {
    for (index, element) in sequence.enumerated() {
        if predicate(element) {
            return index
        }
    }
    return nil
}
