//
//  OptionPickerFormItem.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 20-06-15.
//  Copyright © 2015 Simon Strandgaard. All rights reserved.
//

import Foundation

open class OptionRowModel {
	open let title: String
	open let identifier: String
	
	public init(_ title: String, _ identifier: String) {
		self.title = title
		self.identifier = identifier
	}
}

open class OptionPickerFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitOptionPicker(self)
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
	
	open var options = [OptionRowModel]()
	open func append(_ name: String, identifier: String? = nil) -> Self {
		options.append(OptionRowModel(name, identifier ?? name))
		return self
	}
	
	open func selectOptionWithTitle(_ title: String) {
		for option in options {
			if option.title == title {
				self.setSelectedOptionRow(option)
				DLog("initial selected option: \(option.title)")
			}
		}
	}
	
	typealias SyncBlock = (_ selected: OptionRowModel?) -> Void
	var syncCellWithValue: SyncBlock = { (selected: OptionRowModel?) in
		DLog("sync is not overridden")
	}
	
	internal var innerSelected: OptionRowModel? = nil
	open var selected: OptionRowModel? {
		get {
			return self.innerSelected
		}
		set {
			self.setSelectedOptionRow(newValue)
		}
	}
	
	open func setSelectedOptionRow(_ selected: OptionRowModel?) {
		DLog("option: \(selected?.title)")
		innerSelected = selected
		syncCellWithValue(selected)
	}
}

open class OptionRowFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitOptionRow(self)
	}
	
	open var title: String = ""
	open func title(_ title: String) -> Self {
		self.title = title
		return self
	}
	
	open var selected: Bool = false
	
	open var context: AnyObject?
}
