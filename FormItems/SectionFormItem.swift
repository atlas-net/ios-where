//
//  SectionFormItem.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 20-06-15.
//  Copyright © 2015 Simon Strandgaard. All rights reserved.
//

import Foundation

open class SectionFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitSection(self)
	}
}

open class SectionHeaderTitleFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitSectionHeaderTitle(self)
	}
	
	open var title: String?
	open func title(_ title: String) -> Self {
		self.title = title
		return self
	}
}

open class SectionHeaderViewFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitSectionHeaderView(self)
	}
	
	public typealias CreateUIView = (Void) -> UIView?
	open var viewBlock: CreateUIView?
}

open class SectionFooterTitleFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitSectionFooterTitle(self)
	}
	
	open var title: String?
	open func title(_ title: String) -> Self {
		self.title = title
		return self
	}
}

open class SectionFooterViewFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitSectionFooterView(self)
	}
	
	public typealias CreateUIView = (Void) -> UIView?
	open var viewBlock: CreateUIView?
}
