//
//  ValidateVisitor.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 23/11/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import Foundation

class ValidateVisitor: NSObject, FormItemVisitor {
	var result = ValidateResult.valid
	
	func visitMeta(_ object: MetaFormItem) {}
	func visitStaticText(_ object: StaticTextFormItem) {}
	
	func visitTextField(_ object: TextFieldFormItem) {
		result = object.submitValidateValueText()
	}
	
	func visitTextView(_ object: TextViewFormItem) {}
	func visitViewController(_ object: ViewControllerFormItem) {}
	func visitOptionPicker(_ object: OptionPickerFormItem) {}
	func visitDatePicker(_ object: DatePickerFormItem) {}
	func visitButton(_ object: ButtonFormItem) {}
	func visitOptionRow(_ object: OptionRowFormItem) {}
	func visitSwitch(_ object: SwitchFormItem) {}
	func visitStepper(_ object: StepperFormItem) {}
	func visitSlider(_ object: SliderFormItem) {}
	func visitSection(_ object: SectionFormItem) {}
	func visitSectionHeaderTitle(_ object: SectionHeaderTitleFormItem) {}
	func visitSectionHeaderView(_ object: SectionHeaderViewFormItem) {}
	func visitSectionFooterTitle(_ object: SectionFooterTitleFormItem) {}
	func visitSectionFooterView(_ object: SectionFooterViewFormItem) {}
}
