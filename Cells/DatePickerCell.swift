//
//  DatePickerCell.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 08/11/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import UIKit

public struct DatePickerCellModel {
	var title: String = ""
	var toolbarMode: ToolbarMode = .simple
	var datePickerMode: UIDatePickerMode = .dateAndTime
	var locale: Locale? = nil // default is [NSLocale currentLocale]. setting nil returns to default
	var minimumDate: Date? = nil // specify min/max date range. default is nil. When min > max, the values are ignored. Ignored in countdown timer mode
	var maximumDate: Date? = nil // default is nil
	
	var valueDidChange: (Date) -> Void = { (date: Date) in
		DLog("date \(date)")
	}
}

open class DatePickerCell: UITableViewCell, SelectRowDelegate {
	open let model: DatePickerCellModel

	public init(model: DatePickerCellModel) {
		/*
		Known problem: UIDatePickerModeCountDownTimer is buggy and therefore not supported
		
		UIDatePicker has a bug in it when used in UIDatePickerModeCountDownTimer mode. The picker does not fire the target-action
		associated with the UIControlEventValueChanged event the first time the user changes the value by scrolling the wheels.
		It works fine for subsequent changes.
		http://stackoverflow.com/questions/20181980/uidatepicker-bug-uicontroleventvaluechanged-after-hitting-minimum-internal
		http://stackoverflow.com/questions/19251803/objective-c-uidatepicker-uicontroleventvaluechanged-only-fired-on-second-select
		
		Possible work around: Continuously poll for changes.
		*/
		assert(model.datePickerMode != .countDownTimer, "CountDownTimer is not supported")

		self.model = model
		super.init(style: .value1, reuseIdentifier: nil)
		selectionStyle = .default
		textLabel?.text = model.title
		
		updateValue()
		
		assignDefaultColors()
	}

	public required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	open func assignDefaultColors() {
		textLabel?.textColor = UIColor.black
		detailTextLabel?.textColor = UIColor.gray
	}
	
	open func assignTintColors() {
		let color = self.tintColor
		DLog("assigning tint color: \(color)")
		textLabel?.textColor = color
		detailTextLabel?.textColor = color
	}
	
	open func resolveLocale() -> Locale {
		return model.locale ?? Locale.current
	}
	
	open lazy var datePicker: UIDatePicker = {
		let instance = UIDatePicker()
		instance.datePickerMode = self.model.datePickerMode
		instance.minimumDate = self.model.minimumDate
		instance.maximumDate = self.model.maximumDate
		instance.addTarget(self, action: #selector(DatePickerCell.valueChanged), for: .valueChanged)
		instance.locale = self.resolveLocale()
		return instance
		}()
	

	open lazy var toolbar: SimpleToolbar = {
		let instance = SimpleToolbar()
		weak var weakSelf = self
		instance.jumpToPrevious = {
			if let cell = weakSelf {
				cell.gotoPrevious()
			}
		}
		instance.jumpToNext = {
			if let cell = weakSelf {
				cell.gotoNext()
			}
		}
		instance.dismissKeyboard = {
			if let cell = weakSelf {
				cell.dismissKeyboard()
			}
		}
		return instance
		}()
	
	open func updateToolbarButtons() {
		if model.toolbarMode == .simple {
			toolbar.updateButtonConfiguration(self)
		}
	}
	
	open func gotoPrevious() {
		DLog("make previous cell first responder")
		form_makePreviousCellFirstResponder()
	}
	
	open func gotoNext() {
		DLog("make next cell first responder")
		form_makeNextCellFirstResponder()
	}
	
	open func dismissKeyboard() {
		DLog("dismiss keyboard")
		resignFirstResponder()
	}
	
	open override var inputView: UIView? {
		return datePicker
	}
	
	open override var inputAccessoryView: UIView? {
		if model.toolbarMode == .simple {
			return toolbar
		}
		return nil
	}

	open func valueChanged() {
		let date = datePicker.date
		model.valueDidChange(date)

		updateValue()
	}
	
	open func obtainDateStyle(_ datePickerMode: UIDatePickerMode) -> DateFormatter.Style {
		switch datePickerMode {
		case .time:
			return .none
		case .date:
			return .long
		case .dateAndTime:
			return .short
		case .countDownTimer:
			return .none
		}
	}
	
	open func obtainTimeStyle(_ datePickerMode: UIDatePickerMode) -> DateFormatter.Style {
		switch datePickerMode {
		case .time:
			return .short
		case .date:
			return .none
		case .dateAndTime:
			return .short
		case .countDownTimer:
			return .short
		}
	}
	
	open func humanReadableValue() -> String {
		if model.datePickerMode == .countDownTimer {
			let t = datePicker.countDownDuration
			let date = Date(timeIntervalSinceReferenceDate: t)
			var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
			calendar.timeZone = TimeZone(secondsFromGMT: 0)!
			let components = (calendar as NSCalendar).components([NSCalendar.Unit.hour, NSCalendar.Unit.minute], from: date)
			let hour = components.hour
			let minute = components.minute
			return String(format: "%02d:%02d", hour!, minute!)
		}
		if true {
			let date = datePicker.date
			//DLog("date: \(date)")
			let dateFormatter = DateFormatter()
			dateFormatter.locale = self.resolveLocale()
			dateFormatter.dateStyle = obtainDateStyle(model.datePickerMode)
			dateFormatter.timeStyle = obtainTimeStyle(model.datePickerMode)
			return dateFormatter.string(from: date)
		}
	}

	open func updateValue() {
		detailTextLabel?.text = humanReadableValue()
	}
	
	open func setDateWithoutSync(_ date: Date?, animated: Bool) {
		DLog("set date \(date), animated \(animated)")
		datePicker.setDate(date ?? Date(), animated: animated)
		updateValue()
	}

	open func form_didSelectRow(_ indexPath: IndexPath, tableView: UITableView) {
		// Hide the datepicker wheel, if it's already visible
		// Otherwise show the datepicker
		
		let alreadyFirstResponder = (self.form_firstResponder() != nil)
		if alreadyFirstResponder {
			tableView.form_firstResponder()?.resignFirstResponder()
			tableView.deselectRow(at: indexPath, animated: true)
			return
		}
		
		//DLog("will invoke")
		// hide keyboard when the user taps this kind of row
		tableView.form_firstResponder()?.resignFirstResponder()
		self.becomeFirstResponder()
		tableView.deselectRow(at: indexPath, animated: true)
		//DLog("did invoke")
	}
	
	// MARK: UIResponder
	
	open override var canBecomeFirstResponder : Bool {
		return true
	}
	
	open override func becomeFirstResponder() -> Bool {
		let result = super.becomeFirstResponder()
		updateToolbarButtons()
		assignTintColors()
		return result
	}
	
	open override func resignFirstResponder() -> Bool {
		super.resignFirstResponder()
		assignDefaultColors()
		return true
	}
}
