//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
import Foundation

// http://stackoverflow.com/questions/24114288/macros-in-swift
#if DEBUG
	func DLog(message: String, function: String = #function, file: String = #file, line: Int = #line) {
		print("[\(file.lastPathComponent):\(line)] \(function) - \(message)")
	}
#else
	func DLog(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
		// do nothing
	}
#endif


