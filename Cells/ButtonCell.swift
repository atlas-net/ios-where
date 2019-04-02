//
//  ButtonCell.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 08/11/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import UIKit

public struct ButtonCellModel {
	var title: String = ""
    var colors: [CGColor?] = []
	
	var action: (Void) -> Void = {
		DLog("action")
	}

}

open class ButtonCell: UITableViewCell, SelectRowDelegate {
	open let model: ButtonCellModel
	
	public init(model: ButtonCellModel) {
		self.model = model
		super.init(style: .default, reuseIdentifier: nil)
		loadWithModel(model)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open func loadWithModel(_ model: ButtonCellModel) {
		textLabel?.text = model.title
		textLabel?.textAlignment = NSTextAlignment.center
        textLabel?.textColor = UIColor.white

        if model.colors.count > 1 {
            let color = UIColor(cgColor: model.colors[1]!)
            backgroundColor = color
            delay(0.2) { self.addGradientWithColors(model.colors as [AnyObject]) }
        } else if model.colors.count == 1 {
            backgroundColor = UIColor(cgColor: model.colors[0]!)
        } else {
            backgroundColor = Config.Colors.ButtonDarkPink
        }
	}

	open func form_didSelectRow(_ indexPath: IndexPath, tableView: UITableView) {
		// hide keyboard when the user taps this kind of row
		tableView.form_firstResponder()?.resignFirstResponder()
		
		model.action()
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
}
