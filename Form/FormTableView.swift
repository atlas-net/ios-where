//
//  FormTableView.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 09/11/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import UIKit

open class FormTableView: UITableView {

	public init() {
		super.init(frame: CGRect.zero, style: .grouped)
		contentInset = UIEdgeInsets.zero
		scrollIndicatorInsets = UIEdgeInsets.zero
        separatorStyle = UITableViewCellSeparatorStyle.none
        self.backgroundColor = UIColor.clear
	}

	public required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
}
