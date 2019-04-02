//
//  DumpVisitor.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 23/11/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import Foundation

open class DumpVisitor: FormItemVisitor {
	public init() {
	}
	
	class func dump(_ prettyPrinted: Bool = true, items: [FormItem]) -> Data {
		var result = [Dictionary<String, AnyObject>]()
		var rowNumber: Int = 0
		for item in items {
			let dumpVisitor = DumpVisitor()
			item.accept(dumpVisitor)
			
			
			var dict = Dictionary<String, AnyObject>()
			dict["row"] = rowNumber as AnyObject?
			
			let validateVisitor = ValidateVisitor()
			item.accept(validateVisitor)
			switch validateVisitor.result {
			case .valid:
				dict["validate-status"] = "ok" as AnyObject?
			case .hardInvalid(let message):
				dict["validate-status"] = "hard-invalid" as AnyObject?
				dict["validate-message"] = message as AnyObject?
			case .softInvalid(let message):
				dict["validate-status"] = "soft-invalid" as AnyObject?
				dict["validate-message"] = message as AnyObject?
			}
			
			dict.update(dumpVisitor.dict)
			
			result.append(dict)
			rowNumber += 1
		}
		
        let options: JSONSerialization.WritingOptions = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions()
        //var error: NSError?
        let data: Data?
		do {
			data = try JSONSerialization.data(withJSONObject: result, options: options)
		} catch let error1 as NSError {
			//error = error1
			data = nil
		}
        if let data = data {
            return data
        }
		return Data()
	}
	
	fileprivate var dict = Dictionary<String, AnyObject>()
	
	open func visitMeta(_ object: MetaFormItem) {
		dict["class"] = "MetaFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
		dict["value"] = object.value
	}

	open func visitStaticText(_ object: StaticTextFormItem) {
		dict["class"] = "StaticTextFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
		dict["title"] = object.title as AnyObject?
		dict["value"] = object.value as AnyObject?
	}
	
	open func visitTextField(_ object: TextFieldFormItem) {
		dict["class"] = "TextFieldFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
		dict["title"] = object.title as AnyObject?
		dict["value"] = object.value as AnyObject?
		dict["placeholder"] = object.placeholder as AnyObject?
	}
	
	open func visitTextView(_ object: TextViewFormItem) {
		dict["class"] = "TextViewFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
		dict["title"] = object.title as AnyObject?
		dict["value"] = object.value as AnyObject?
	}
	
	open func visitViewController(_ object: ViewControllerFormItem) {
		dict["class"] = "ViewControllerFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
		dict["title"] = object.title as AnyObject?
	}
	
	open func visitOptionPicker(_ object: OptionPickerFormItem) {
		dict["class"] = "OptionPickerFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
		dict["title"] = object.title as AnyObject?
		dict["placeholder"] = object.placeholder as AnyObject?
	}
	
	func convertOptionalDateToJSON(_ date: Date?) -> AnyObject {
		if let date = date {
			return date.description as AnyObject
		}
		return NSNull()
	}
	
	open func visitDatePicker(_ object: DatePickerFormItem) {
		dict["class"] = "DatePickerFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
		dict["title"] = object.title as AnyObject?
		dict["date"] = convertOptionalDateToJSON(object.value as Date?)
		dict["datePickerMode"] = object.datePickerMode.description as AnyObject?
		dict["locale"] = object.locale as AnyObject?? ?? NSNull()
		dict["minimumDate"] = convertOptionalDateToJSON(object.minimumDate as Date?)
		dict["maximumDate"] = convertOptionalDateToJSON(object.minimumDate as Date?)
	}
	
	open func visitButton(_ object: ButtonFormItem) {
		dict["class"] = "ButtonFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
		dict["title"] = object.title as AnyObject?
	}
	
	open func visitOptionRow(_ object: OptionRowFormItem) {
		dict["class"] = "OptionRowFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
		dict["title"] = object.title as AnyObject?
		dict["state"] = object.selected as AnyObject?
	}

	open func visitSwitch(_ object: SwitchFormItem) {
		dict["class"] = "SwitchFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
		dict["title"] = object.title as AnyObject?
		dict["value"] = object.value as AnyObject?
	}

	open func visitStepper(_ object: StepperFormItem) {
		dict["class"] = "StepperFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
		dict["title"] = object.title as AnyObject?
	}
	
	open func visitSlider(_ object: SliderFormItem) {
		dict["class"] = "SliderFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
		dict["value"] = object.value as AnyObject?
		dict["minimumValue"] = object.minimumValue as AnyObject?
		dict["maximumValue"] = object.maximumValue as AnyObject?
	}
	
	open func visitSection(_ object: SectionFormItem) {
		dict["class"] = "SectionFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
	}
	
	open func visitSectionHeaderTitle(_ object: SectionHeaderTitleFormItem) {
		dict["class"] = "SectionHeaderTitleFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
		dict["title"] = object.title as AnyObject?
	}
	
	open func visitSectionHeaderView(_ object: SectionHeaderViewFormItem) {
		dict["class"] = "SectionHeaderViewFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
	}
	
	open func visitSectionFooterTitle(_ object: SectionFooterTitleFormItem) {
		dict["class"] = "SectionFooterTitleFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
		dict["title"] = object.title as AnyObject?
	}

	open func visitSectionFooterView(_ object: SectionFooterViewFormItem) {
		dict["class"] = "SectionFooterViewFormItem" as AnyObject?
		dict["elementIdentifier"] = object.elementIdentifier as AnyObject?
		dict["styleIdentifier"] = object.styleIdentifier as AnyObject?
		dict["styleClass"] = object.styleClass as AnyObject?
	}
}
