//
//  MetaFormItem.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 20-06-15.
//  Copyright © 2015 Simon Strandgaard. All rights reserved.
//

import Foundation

/// This is an invisible field, that is submitted along with the json
open class MetaFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitMeta(self)
	}
	
	open var value: AnyObject?
	open func value(_ value: AnyObject?) -> Self {
		self.value = value
		return self
	}
}
