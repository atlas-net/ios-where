//
//  OptionViewControllerCell.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 14/12/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import UIKit

public struct OptionViewControllerCellModel {
	var title: String = ""
	var placeholder: String = ""
	var optionField: OptionPickerFormItem? = nil

	var valueDidChange: (OptionRowModel?) -> Void = { (value: OptionRowModel?) in
		DLog("value \(value)")
	}
}

open class OptionViewControllerCell: UITableViewCell, SelectRowDelegate {
	open let model: OptionViewControllerCellModel
	open var selectedOptionRow: OptionRowModel? = nil
	weak var parentViewController: UIViewController?
	
	public init(model: OptionViewControllerCellModel) {
		self.model = model
		super.init(style: .value1, reuseIdentifier: nil)
		accessoryType = .disclosureIndicator
		textLabel?.text = model.title
		detailTextLabel?.text = model.placeholder
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open func humanReadableValue() -> String? {
		if let option = selectedOptionRow {
			return option.title
		} else {
			return model.placeholder
		}
	}
	
	open func updateValue() {
		let s = humanReadableValue()
		DLog("update value \(s)")
		detailTextLabel?.text = humanReadableValue()
	}
	
	open func setValueWithoutSync(_ value: OptionRowModel?) {
		DLog("set value \(value)")
		selectedOptionRow = value
		updateValue()
	}
	
	open func setValueAndSync(_ value: OptionRowModel?) {
		selectedOptionRow = value
		model.valueDidChange(selectedOptionRow)
		updateValue()
	}

	open func form_didSelectRow(_ indexPath: IndexPath, tableView: UITableView) {
		DLog("will invoke")
		// hide keyboard when the user taps this kind of row
		tableView.form_firstResponder()?.resignFirstResponder()
		
		weak var weakCell = self
		let dismissCommand = CommandBlock { (childViewController: UIViewController, returnObject: AnyObject?) in
			if let cell = weakCell {
				if let pickedOption = returnObject as? OptionRowModel {
					DLog("pick ok")
					cell.setValueAndSync(pickedOption)
				} else {
					DLog("pick none")
					cell.setValueAndSync(nil)
				}
			}
			childViewController.navigationController?.popViewController(animated: true)
			return
		}
		
		if let vc = parentViewController {
			if let optionField = model.optionField {
				let childViewController = OptionViewController(dismissCommand: dismissCommand, optionField: optionField)
				vc.navigationController?.pushViewController(childViewController, animated: true)
			}
		}

		DLog("did invoke")
	}
}
