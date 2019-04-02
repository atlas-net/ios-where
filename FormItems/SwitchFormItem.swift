//
//  SwitchFormItem.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 20-06-15.
//  Copyright © 2015 Simon Strandgaard. All rights reserved.
//

import Foundation

open class SwitchFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitSwitch(self)
	}
	
	open var title: String = ""
	open func title(_ title: String) -> Self {
		self.title = title
		return self
	}
	
    open var onValueChanged: ((Void) -> Void)?
    
	typealias SyncBlock = (_ value: Bool, _ animated: Bool) -> Void
	var syncCellWithValue: SyncBlock = { (value: Bool, animated: Bool) in
		DLog("sync is not overridden")
	}
	
    internal var innerValue: Bool = false {
        didSet {
            onValueChanged?()
        }
    }
	open var value: Bool {
		get {
			return self.innerValue
		}
		set {
			self.setValue(newValue, animated: false)
		}
	}
	
	open func setValue(_ value: Bool, animated: Bool) {
		innerValue = value
		syncCellWithValue(value, animated)
	}
}
