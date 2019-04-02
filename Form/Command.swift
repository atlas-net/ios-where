//
//  Command.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 12/11/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import UIKit

public protocol CommandProtocol {
	func execute(_ viewController: UIViewController, returnObject: AnyObject?)
}

open class CommandBlock: CommandProtocol {
	open let block: (UIViewController, AnyObject?) -> Void
	public init(block: @escaping (UIViewController, AnyObject?) -> Void) {
		self.block = block
	}
	
	open func execute(_ viewController: UIViewController, returnObject: AnyObject?) {
		block(viewController, returnObject)
	}
}
