//
//  StaticTextFormItem.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 20-06-15.
//  Copyright © 2015 Simon Strandgaard. All rights reserved.
//

import Foundation

open class StaticTextFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitStaticText(self)
	}
	
	open var title: String = ""
	open func title(_ title: String) -> Self {
		self.title = title
		return self
	}
	
	open var value: String = ""
	open func value(_ value: String) -> Self {
		self.value = value
		return self
	}
}
