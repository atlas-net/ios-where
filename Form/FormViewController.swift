//
//  FormViewController.swift
//  SwiftyFORM
//
//  Created by Simon Strandgaard on 09/11/14.
//  Copyright (c) 2014 Simon Strandgaard. All rights reserved.
//

import UIKit

open class FormViewController: UIViewController {
	open var dataSource: TableViewSectionArray?
	open var keyboardHandler: KeyboardHandler?
	
	public init() {
		DLog("super init")
		super.init(nibName: nil, bundle: nil)
	}
	
	required public init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	override open func loadView() {
        super.loadView()
		DLog("super loadview")
		
        view.backgroundColor = Config.Colors.MainContentBackgroundWhite

        
		keyboardHandler = KeyboardHandler(tableView: self.tableView)
		
		self.populate(formBuilder)
		self.title = formBuilder.navigationTitle
		
		dataSource = formBuilder.result(self)
		self.tableView.dataSource = dataSource
		self.tableView.delegate = dataSource
        self.tableView.frame = CGRect(x: 15, y: 0, width: self.view.frame.size.width - 30, height: self.view.frame.size.height)
        self.view.addSubview(tableView)
	}

	open func populate(_ builder: FormBuilder) {
		print("subclass must implement populate()", terminator: "")
	}

	override open func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.keyboardHandler?.addObservers()

		// Fade out, so that the user can see what row has been updated
        if let indexPath: IndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
	}
	
	override open func viewDidDisappear(_ animated: Bool) {
		self.keyboardHandler?.removeObservers()
		super.viewDidDisappear(animated)
	}

	open lazy var formBuilder: FormBuilder = {
		return FormBuilder()
		}()
	
	open lazy var tableView: FormTableView = {
		return FormTableView()
		}()
	
}
