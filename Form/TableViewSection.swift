//
//  TableViewSection.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 23/10/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import UIKit

public enum TableViewSectionPart {
	case none
	case titleString(string: String)
	case titleView(view: UIView)
	
	typealias CreateBlock = (Void) -> TableViewSectionPart
	
	func title() -> String? {
		switch self {
		case let .titleString(string):
			return string
		default:
			return nil
		}
	}

	func view() -> UIView? {
		switch self {
		case let .titleView(view):
			return view
		default:
			return nil
		}
	}
	
	func height() -> CGFloat {
		switch self {
		case let .titleView(view):
			let view2: UIView = view
			return view2.frame.size.height
		default:
			return UITableViewAutomaticDimension
		}
	}
}

open class TableViewSection : NSObject, UITableViewDataSource, UITableViewDelegate {
	fileprivate let cells: [UITableViewCell]
	fileprivate let headerBlock: TableViewSectionPart.CreateBlock
	fileprivate let footerBlock: TableViewSectionPart.CreateBlock
	
	init(cells: [UITableViewCell], headerBlock: @escaping TableViewSectionPart.CreateBlock, footerBlock: @escaping TableViewSectionPart.CreateBlock) {
		self.cells = cells
		self.headerBlock = headerBlock
		self.footerBlock = footerBlock
		super.init()
	}

	fileprivate lazy var header: TableViewSectionPart = {
		return self.headerBlock()
		}()

	fileprivate lazy var footer: TableViewSectionPart = {
		return self.footerBlock()
		}()

	
	open func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cells.count
	}
	
	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return cells[(indexPath as NSIndexPath).row]
	}
	
	open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return header.title()
	}
	
	open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return footer.title()
	}

	open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return header.view()
	}

	open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return footer.view()
	}

	open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return header.height()
	}
	
	open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return footer.height()
	}
	
	open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let cell = cells[(indexPath as NSIndexPath).row] as? SelectRowDelegate {
			cell.form_didSelectRow(indexPath, tableView: tableView)
		}
	}
	
	open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if let cell = cells[(indexPath as NSIndexPath).row] as? CellHeightProvider {
			return cell.form_cellHeight(indexPath, tableView: tableView)
		}
		return 44
	}
	
}


/// UITableView with multiple sections
open class TableViewSectionArray : NSObject, UITableViewDataSource, UITableViewDelegate {
	public typealias SectionType = NSObjectProtocol & UITableViewDataSource & UITableViewDelegate
	
	fileprivate var sections: [SectionType]
	
	public init(sections: [SectionType]) {
		self.sections = sections
		super.init()
	}
	
	open func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}
	
	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].tableView(tableView, numberOfRowsInSection: section)
	}
	
	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return sections[(indexPath as NSIndexPath).section].tableView(tableView, cellForRowAt: indexPath)
	}
	
	open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		sections[(indexPath as NSIndexPath).section].tableView?(tableView, didSelectRowAt: indexPath)
	}
	
	open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section].tableView?(tableView, titleForHeaderInSection: section)
	}

	open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return sections[section].tableView?(tableView, titleForFooterInSection: section)
	}
	open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return sections[section].tableView?(tableView, viewForHeaderInSection: section)
	}
	
	open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return sections[section].tableView?(tableView, viewForFooterInSection: section)
	}
	
	open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return sections[section].tableView?(tableView, heightForHeaderInSection: section) ?? UITableViewAutomaticDimension
	}
	
	open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return sections[section].tableView?(tableView, heightForFooterInSection: section) ?? UITableViewAutomaticDimension
	}
	
	open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return sections[(indexPath as NSIndexPath).section].tableView?(tableView, heightForRowAt: indexPath) ?? 0
	}
	
	
	// MARK: UIScrollViewDelegate
	
	/// hide keyboard when the user starts scrolling
	open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		scrollView.form_firstResponder()?.resignFirstResponder()
	}
	
	/// hide keyboard when the user taps the status bar
	open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
		scrollView.form_firstResponder()?.resignFirstResponder()
		return true
	}
}

