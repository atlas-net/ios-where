//
//  SliderFormItem.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 20-06-15.
//  Copyright © 2015 Simon Strandgaard. All rights reserved.
//

import Foundation

open class SliderFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitSlider(self)
	}
	
	open var minimumValue: Float = 0.0
	open func minimumValue(_ minimumValue: Float) -> Self {
		self.minimumValue = minimumValue
		return self
	}
	
	open var maximumValue: Float = 1.0
	open func maximumValue(_ maximumValue: Float) -> Self {
		self.maximumValue = maximumValue
		return self
	}
	
	
	typealias SyncBlock = (_ value: Float, _ animated: Bool) -> Void
	var syncCellWithValue: SyncBlock = { (value: Float, animated: Bool) in
		DLog("sync is not overridden")
	}
	
	internal var innerValue: Float = 0.0
	open var value: Float {
		get {
			return self.innerValue
		}
		set {
			self.setValue(newValue, animated: false)
		}
	}
	open func value(_ value: Float) -> Self {
		setValue(value, animated: false)
		return self
	}
	
	open func setValue(_ value: Float, animated: Bool) {
		innerValue = value
		syncCellWithValue(value, animated)
	}
}
