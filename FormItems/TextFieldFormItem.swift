//
//  TextFieldFormItem.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 20-06-15.
//  Copyright © 2015 Simon Strandgaard. All rights reserved.
//

import Foundation

open class TextFieldFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitTextField(self)
	}
	
	open var keyboardType: UIKeyboardType = .default
	open func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
		self.keyboardType = keyboardType
		return self
	}
	
	
	open var autocorrectionType: UITextAutocorrectionType = .no
	open var autocapitalizationType: UITextAutocapitalizationType = .none
	open var spellCheckingType: UITextSpellCheckingType = .no
	open var secureTextEntry = false
	
	open var returnKeyType: UIReturnKeyType = .default
	open func returnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
		self.returnKeyType = returnKeyType
		return self
	}
	
	
	typealias SyncBlock = (_ value: String) -> Void
	var syncCellWithValue: SyncBlock = { (string: String) in
		DLog("sync is not overridden")
	}
	
	internal var innerValue: String = ""
	open var value: String {
		get {
			return self.innerValue
		}
		set {
			self.assignValueAndSync(newValue)
		}
	}
	
	func assignValueAndSync(_ value: String) {
		innerValue = value
		syncCellWithValue(value)
	}
	
	var reloadPersistentValidationState: (Void) -> Void = {}
	
	
	var obtainTitleWidth: (Void) -> CGFloat = {
		return 0
	}
	
	var assignTitleWidth: (CGFloat) -> Void = { (width: CGFloat) in
		// do nothing
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
	
	open func password() -> Self {
		self.secureTextEntry = true
		return self
	}
	
	let validatorBuilder = ValidatorBuilder()
	
	open func validate(_ specification: Specification, message: String) -> Self {
		validatorBuilder.hardValidate(specification, message: message)
		return self
	}
	
	open func softValidate(_ specification: Specification, message: String) -> Self {
		validatorBuilder.softValidate(specification, message: message)
		return self
	}
	
	open func submitValidate(_ specification: Specification, message: String) -> Self {
		validatorBuilder.submitValidate(specification, message: message)
		return self
	}
	
	open func required(_ message: String) -> Self {
		submitValidate(CountSpecification.min(1), message: message)
		return self
	}
	
	open func liveValidateValueText() -> ValidateResult {
		return  validatorBuilder.build().liveValidate(self.value)
	}
	
	open func liveValidateText(_ text: String) -> ValidateResult {
		return validatorBuilder.build().validate(text, checkHardRule: true, checkSoftRule: true, checkSubmitRule: false)
	}
	
	open func submitValidateValueText() -> ValidateResult {
		return validatorBuilder.build().submitValidate(self.value)
	}
	
	open func submitValidateText(_ text: String) -> ValidateResult {
		return validatorBuilder.build().validate(text, checkHardRule: true, checkSoftRule: true, checkSubmitRule: true)
	}
	
	open func validateText(_ text: String, checkHardRule: Bool, checkSoftRule: Bool, checkSubmitRule: Bool) -> ValidateResult {
		return validatorBuilder.build().validate(text, checkHardRule: checkHardRule, checkSoftRule: checkSoftRule, checkSubmitRule: checkSubmitRule)
	}
}
