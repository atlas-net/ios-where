//
//  SwitchCell.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 24/11/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import UIKit

public struct SwitchCellModel {
	var title: String = ""
    var value: Bool = false
    
	var valueDidChange: (Bool) -> Void = { (value: Bool) in

	}
}

open class SwitchCell: UITableViewCell {
	open var model: SwitchCellModel
	open let switchView: UISwitch
	
	public init(model: SwitchCellModel) {
		self.model = model
		self.switchView = UISwitch()
		super.init(style: .default, reuseIdentifier: nil)
		selectionStyle = .none
		textLabel?.text = model.title
        backgroundColor = Config.Colors.TagFieldBackground
		textLabel?.textColor = Config.Colors.MainContentColorBlack
        
		switchView.addTarget(self, action: #selector(SwitchCell.valueChanged), for: .valueChanged)
		accessoryView = switchView
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open func valueChanged() {
		DLog("value did change")
		model.valueDidChange(switchView.isOn)
        model.value = switchView.isOn
	}

	open func setValueWithoutSync(_ value: Bool, animated: Bool) {
		DLog("set value \(value), animated \(animated)")
		switchView.setOn(value, animated: animated)
        model.value = value
	}
	
}

