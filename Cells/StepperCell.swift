//
//  StepperCell.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 24/11/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import UIKit

public struct StepperCellModel {
	var title: String = ""
}

open class StepperCell: UITableViewCell {
	open let model: StepperCellModel
	open let valueLabel = UILabel()
	open let stepperView = UIStepper()
	open var containerView = UIView()
	
	public init(model: StepperCellModel) {
		self.model = model
		super.init(style: .value1, reuseIdentifier: nil)
		selectionStyle = .none
		textLabel?.text = model.title

		valueLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
		valueLabel.textColor = UIColor.gray
		containerView.addSubview(stepperView)
		containerView.addSubview(valueLabel)
		accessoryView = containerView

		stepperView.addTarget(self, action: #selector(StepperCell.valueChanged), for: .valueChanged)

		valueLabel.text = "0"
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		stepperView.sizeToFit()
		valueLabel.sizeToFit()
		
		let rightPadding: CGFloat = 17
		let valueStepperPadding: CGFloat = 10
		
		let valueSize = valueLabel.frame.size
		let stepperSize = stepperView.frame.size
		
		let containerWidth = ceil(valueSize.width + valueStepperPadding + stepperSize.width)
		containerView.frame = CGRect(x: bounds.width - rightPadding - containerWidth, y: 0, width: containerWidth, height: stepperSize.height)
		
		let valueY: CGFloat = bounds.midY - valueSize.height / 2
		valueLabel.frame = CGRect(x: 0, y: valueY, width: valueSize.width, height: valueSize.height).integral
		
		let stepperY: CGFloat = bounds.midY - stepperSize.height / 2
		stepperView.frame = CGRect(x: containerWidth - stepperSize.width, y: stepperY, width: stepperSize.width, height: stepperSize.height)
	}
	
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open func valueChanged() {
		DLog("value did change")
		
		let value: Double = stepperView.value
		let valueInt: Int = Int(round(value))
		
		self.valueLabel.text = "\(valueInt)"
		setNeedsLayout()
	}
}

