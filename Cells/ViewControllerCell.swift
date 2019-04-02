//
//  ViewControllerCell.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 05/11/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import UIKit

open class ViewControllerFormItemCellModel {
	open let title: String
	open let placeholder: String
    open var tapHandler: (()->())?
	public init(title: String, placeholder: String) {
		self.title = title
		self.placeholder = placeholder
	}
}

open class ViewControllerFormItemCell: UITableViewCell, SelectRowDelegate {
	open let model: ViewControllerFormItemCellModel
	let innerDidSelectRow: (ViewControllerFormItemCell, ViewControllerFormItemCellModel) -> Void

	public init(model: ViewControllerFormItemCellModel, didSelectRow: @escaping (ViewControllerFormItemCell, ViewControllerFormItemCellModel) -> Void) {
		self.model = model
		self.innerDidSelectRow = didSelectRow
		super.init(style: .value1, reuseIdentifier: nil)
		accessoryType = .disclosureIndicator
		textLabel?.text = model.title
		detailTextLabel?.text = model.placeholder
        textLabel?.font = UIFont.systemFont(ofSize: 15)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
        backgroundColor = UIColor.white
        if let textLabel = textLabel {
            textLabel.textColor = Config.Colors.MainContentColorBlack
        }
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open func form_didSelectRow(_ indexPath: IndexPath, tableView: UITableView) {
		DLog("will invoke")
		// hide keyboard when the user taps this kind of row
		tableView.form_firstResponder()?.resignFirstResponder()

		innerDidSelectRow(self, model)
		DLog("did invoke")
        if let tapHandler = model.tapHandler {
            tapHandler()
            tableView.deselectRow(at: indexPath, animated: true)
        }
	}
}
