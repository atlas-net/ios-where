//
//  StaticTextCell.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 08/11/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import UIKit

public struct StaticTextCellModel {
	var title: String = ""
	var value: String = ""
}

open class StaticTextCell: UITableViewCell {
	open let model: StaticTextCellModel

	public init(model: StaticTextCellModel) {
		self.model = model
		super.init(style: .value1, reuseIdentifier: nil)
		loadWithModel(model)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open func loadWithModel(_ model: StaticTextCellModel) {
		selectionStyle = .none
		textLabel?.text = model.title
		detailTextLabel?.text = model.value
        backgroundColor = Config.Colors.TagFieldBackground
        textLabel?.textColor = Config.Colors.MainContentColorBlack
        detailTextLabel?.textColor = UIColor.lightGray
	}

}
