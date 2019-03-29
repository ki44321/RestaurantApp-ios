//
//  ViewController.swift
//  RestaurantApp
//
//  Created by Victor on 26.03.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

protocol ViewControllerInputable {
	var model: Restaurantable? { get set }
}

class DetailViewController: UIViewController, ViewControllerInputable {
	// MARK: Properties
	@IBOutlet private weak var doneButton: UIBarButtonItem! {
		didSet {
			if let font = UIFont.regularFont {
				doneButton.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
			}
		}
	}
	@IBOutlet private weak var restaurantLabel: UILabel!
	
	// MARK: Public variables
	var model: Restaurantable?
	
	// MARK: Controller
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let model = model else {
			_dismiss()
			
			return
		}
		
		restaurantLabel.text = model.restaurant
	}
	
	@IBAction func onDoneAction(_ sender: Any) {
		_dismiss()
	}
	
	// MARK: Private methods
	private func _dismiss() {
		dismiss(animated: true)
	}
}
