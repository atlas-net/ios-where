//
//  ViewControllerFormItem.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 20-06-15.
//  Copyright © 2015 Simon Strandgaard. All rights reserved.
//

import Foundation

open class ViewControllerFormItemPopContext {
	open let parentViewController: UIViewController
	open let childViewController: UIViewController
	open let cell: ViewControllerFormItemCell
	open let returnedObject: AnyObject?
	
	public init(parentViewController: UIViewController, childViewController: UIViewController, cell: ViewControllerFormItemCell, returnedObject: AnyObject?) {
		self.parentViewController = parentViewController
		self.childViewController = childViewController
		self.cell = cell
		self.returnedObject = returnedObject
	}
}

open class ViewControllerFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitViewController(self)
	}
	
    var syncCellWithValue: (String) -> Void = { value in
        DLog("sync is not overridden")
    }

    
	open var placeholder: String = ""
	open func placeholder(_ placeholder: String) -> Self {
		self.placeholder = placeholder
		return self
	}
	
	open var title: String = ""
	open func title(_ title: String) -> Self {
		self.title = title
		return self
	}
    
    open var onItemTapped: ((Void) -> Void)?

	
	open func viewController(_ aClass: UIViewController.Type) -> Self {
		createViewController = { (dismissCommand: CommandProtocol) in
			return aClass.init()
		}
		return self
	}
	
	// the view controller must invoke the dismiss block when it's being dismissed
	public typealias CreateViewController = (CommandProtocol) -> UIViewController?
	open var createViewController: CreateViewController?
	
	// dismissing the view controller
	public typealias PopViewController = (ViewControllerFormItemPopContext) -> Void
	open var willPopViewController: PopViewController?
}
