//
//  TextViewFormItem.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 20-06-15.
//  Copyright © 2015 Simon Strandgaard. All rights reserved.
//

import Foundation

open class TextViewFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitTextView(self)
	}
	
	open var placeholder: String = ""
	open func placeholder(_ placeholder: String) -> Self {
		self.placeholder = placeholder
		return self
	}
	
	open var title: String = ""
	open func title(_ title: String) -> Self {
		self.title = title
		return self
	}
	
	typealias SyncBlock = (_ value: String) -> Void
	var syncCellWithValue: SyncBlock = { (string: String) in
		DLog("sync is not overridden")
	}
	
	internal var innerValue: String = ""
	open var value: String {
		get {
			return self.innerValue
		}
		set {
			self.assignValueAndSync(newValue)
		}
	}
	
	func assignValueAndSync(_ value: String) {
		innerValue = value
		syncCellWithValue(value)
	}
}
