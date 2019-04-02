//
//  Array+InsertionIndex.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/12/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

extension Array {
    func insertionIndexOf(_ elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
}

func insertOrdered<T: Comparable>(_ array: inout [T], elem: T) {
    let index = array.insertionIndexOf(elem, isOrderedBefore: { (a , b) in return (a > b) } )
    return array.insert(elem, at: index)
}

func insertUniqueOrdered<T: Comparable>(_ array: inout [T], elem: T) {
    let index = array.insertionIndexOf(elem, isOrderedBefore: { (a , b) in return (a > b) } )
    
    if index < array.count && array[index] == elem {
        return
    }
    return array.insert(elem, at: index)
}
