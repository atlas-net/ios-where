//
//  DatePickerFormItem.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 20-06-15.
//  Copyright © 2015 Simon Strandgaard. All rights reserved.
//

import Foundation

public enum DatePickerFormItemMode {
	case time
	case date
	case dateAndTime
	
	var description: String {
		switch self {
		case .time: return "Time"
		case .date: return "Date"
		case .dateAndTime: return "DateAndTime"
		}
	}
}

open class DatePickerFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitDatePicker(self)
	}
	
	open var title: String = ""
	open func title(_ title: String) -> Self {
		self.title = title
		return self
	}
	
	typealias SyncBlock = (_ date: Date?, _ animated: Bool) -> Void
	var syncCellWithValue: SyncBlock = { (date: Date?, animated: Bool) in
		DLog("sync is not overridden")
	}
	
	internal var innerValue: Date? = nil
	open var value: Date? {
		get {
			return self.innerValue
		}
		set {
			self.setValue(newValue, animated: false)
		}
	}
	
	open func setValue(_ date: Date?, animated: Bool) {
		innerValue = date
		syncCellWithValue(date, animated)
	}
	
	open var datePickerMode: DatePickerFormItemMode = .dateAndTime
	open var locale: Locale? // default is [NSLocale currentLocale]. setting nil returns to default
	open var minimumDate: Date? // specify min/max date range. default is nil. When min > max, the values are ignored. Ignored in countdown timer mode
	open var maximumDate: Date? // default is nil
}
