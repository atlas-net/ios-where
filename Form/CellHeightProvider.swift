//
//  CellHeightProvider.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 25/11/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import UIKit

@objc protocol CellHeightProvider {
	func form_cellHeight(_ indexPath: IndexPath, tableView: UITableView) -> CGFloat
}
