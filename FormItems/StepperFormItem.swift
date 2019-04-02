//
//  StepperFormItem.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 20-06-15.
//  Copyright © 2015 Simon Strandgaard. All rights reserved.
//

import Foundation

open class StepperFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitStepper(self)
	}
	
	open var title: String = ""
	open func title(_ title: String) -> Self {
		self.title = title
		return self
	}
}
