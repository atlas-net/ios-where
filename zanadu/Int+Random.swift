//
//  Int+Range.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 1/21/16.
//  Copyright © 2016 Atlas. All rights reserved.
//

extension Int {
    init(range: CountableClosedRange<Int> ) {
        let delta = range.lowerBound < 0 ? abs(range.lowerBound) : 0
        let min = UInt32(range.lowerBound + delta)
        let max = UInt32(range.upperBound   + delta)
        self.init(Int(min + arc4random_uniform(max - min)) - delta)
    }
    
    static func random(_ digits:Int) -> Int {
        let min = Int(pow(Double(10), Double(digits-1))) - 1
        let max = Int(pow(Double(10), Double(digits))) - 1
        return Int(range:min...max)
    }
}
