//
//  ValidateResult.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 02/11/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import Foundation

public enum ValidateResult: Equatable {
	case valid
	case hardInvalid(message: String)
	case softInvalid(message: String)
}

public func ==(lhs: ValidateResult, rhs: ValidateResult) -> Bool {
	switch lhs  {
	case .valid:
		switch rhs {
		case .valid:
			return true
		default:
			return false
		}
	case let .hardInvalid(messageA):
		switch rhs {
		case let .hardInvalid(messageB):
			return messageA == messageB
		default:
			return false
		}
	case let .softInvalid(messageA):
		switch rhs {
		case let .softInvalid(messageB):
			return messageA == messageB
		default:
			return false
		}
	}
}
