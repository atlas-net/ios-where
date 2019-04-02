//
//  FormBuilder.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 23/11/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import UIKit

class AlignLeft {
	fileprivate let items: [FormItem]
	init(items: [FormItem]) {
		self.items = items
	}
}

public enum ToolbarMode {
	case none
	case simple
}


open class FormBuilder: NSObject {
	fileprivate var innerItems = [FormItem]()
	fileprivate var alignLeftItems = [AlignLeft]()
	
	override public init() {
		super.init()
	}
	
	open var navigationTitle: String? = nil
	
	open var toolbarMode: ToolbarMode = .none
	
	open func append(_ item: FormItem) -> FormItem {
		innerItems.append(item)
		return item
	}
	
	open func appendMulti(_ items: [FormItem]) {
		innerItems += items
	}
	
	open func alignLeft(_ items: [FormItem]) {
		let alignLeftItem = AlignLeft(items: items)
		alignLeftItems.append(alignLeftItem)
	}
	
	open func alignLeftElementsWithClass(_ styleClass: String) {
		let items: [FormItem] = innerItems.filter { $0.styleClass == styleClass }
		alignLeft(items)
	}
	
	open var items: [FormItem] {
		get { return innerItems }
	}
	
	open func dump(_ prettyPrinted: Bool = true) -> Data {
		return DumpVisitor.dump(prettyPrinted, items: innerItems)
	}
	
	func result(_ viewController: UIViewController) -> TableViewSectionArray {
		let model = PopulateTableViewModel(viewController: viewController, toolbarMode: toolbarMode)
		
		let v = PopulateTableView(model: model)
		for item in innerItems {
			item.accept(v)
		}
		let footerBlock: TableViewSectionPart.CreateBlock = {
			return TableViewSectionPart.none
		}
		v.closeSection(footerBlock)
		
		for alignLeftItem in alignLeftItems {
			let widthArray: [CGFloat] = alignLeftItem.items.map {
				let v = ObtainTitleWidth()
				$0.accept(v)
				return v.width
			}
			//DLog("widthArray: \(widthArray)")
			let width = widthArray.max()!
			//DLog("max width: \(width)")
			
			for item in alignLeftItem.items {
				let v = AssignTitleWidth(width: width)
				item.accept(v)
			}
		}
		
		return TableViewSectionArray(sections: v.sections)
	}
	
	open func validateAndUpdateUI() {
		ReloadPersistentValidationStateVisitor.validateAndUpdateUI(innerItems)
	}
	
	public enum FormValidateResult {
		case valid
		case invalid(item: FormItem, message: String)
	}
	
	open func validate() -> FormValidateResult {
		for item in innerItems {
			let v = ValidateVisitor()
			item.accept(v)
			switch v.result {
			case .valid:
				// DLog("valid")
				continue
			case .hardInvalid(let message):
				//DLog("invalid message \(message)")
				return .invalid(item: item, message: message)
			case .softInvalid(let message):
				//DLog("invalid message \(message)")
				return .invalid(item: item, message: message)
			}
		}
		return .valid
	}
	
}

public func += (left: FormBuilder, right: FormItem) {
	left.append(right)
}

