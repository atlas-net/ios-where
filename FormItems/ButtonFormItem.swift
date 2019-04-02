//
//  ButtonFormItem.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 20-06-15.
//  Copyright © 2015 Simon Strandgaard. All rights reserved.
//

import Foundation

open class ButtonFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitButton(self)
	}
	
	open var title: String = ""
    open var colors: [CGColor?] = []
    
	open func title(_ title: String) -> Self {
		self.title = title
		return self
	}
    
    open func colors(_ colors: [CGColor?]) -> Self {
        self.colors = colors
        return self
    }
	
	open var action: (Void) -> Void = {}
}
