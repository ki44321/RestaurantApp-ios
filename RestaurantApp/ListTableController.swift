//
//  ListTableController.swift
//  RestaurantApp
//
//  Created by Victor on 26.03.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class ListTableController: UITableViewController {
	// MARK: Constants
	private let url = "https://gist.githubusercontent.com/gonchs/b657e6043e17482cae77a633d78f8e83/raw/7654c0db94a3f430888fac0caac675c7e811030a/test_data.json"
	
	// MARK: Private vars
	fileprivate var _lastBottomScrollTS = Date().timeIntervalSince1970
	private var _networkManager: NetworkManagerable!
	private var _data = [Restaurant]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	// MARK: Controller
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_networkManager = NetworkManager<Restaurant>()
		_loadData()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}
	
	// MARK: Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let selectedRow = tableView.indexPathForSelectedRow {
			tableView.deselectRow(at: selectedRow, animated:  false)
			if let model = _data[safe: selectedRow.row] {
				if var controller = segue.destination as? ViewControllerInputable {
					controller.model = model
				}
			}
		}
		
	}
	
	// MARK: Private methods
	private var _isLoading = false
	private func _loadData() {
		if _isLoading {
			return
		}
		
		_isLoading = true
		_networkManager.load(url: url, error: { [weak self] error in
			guard let self = self else {
				return
			}
			
			self._isLoading = false
			
			//TODO: show localized error, e.g use toast or snackbar library
			func showError(_ error: String){
				print(error)
			}
			
			switch error {
			case .emptyResponse: showError("emptyResponse")
			case .noConnection: showError("noConnection")
			case .wrongUrl: showError("wrongUrl")
			case .response(let message): showError(message)
			}
		}) { [weak self] (models: [Restaurant]) in
			guard let self = self else {
				return
			}
			
			self._isLoading = false
			self._data.append(contentsOf: models)
		}
	}
}

// MARK: Table
extension ListTableController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return _data.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "RestaurantCell"
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RestaurantCell else {
			fatalError("Unexpected: RestaurantCell is nil")
		}
		
		if let model = _data[safe: indexPath.row] {
			cell.restaurantLabel.text = model.restaurant
			cell.foodNameLabel.text = model.foodName
			cell.priceLabel.text = model.formattedPrice
			
			if let imageUrl = model.imageUrl {
				cell.logoImage.load(from: imageUrl)
			}
		}
		
		return cell
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let currentOffset = scrollView.contentOffset.y
		let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
		let deltaOffset = maximumOffset - currentOffset
		let lastBottomScrollDiff = Date().timeIntervalSince1970 - _lastBottomScrollTS
		
		if deltaOffset <= 0 && lastBottomScrollDiff > 1 {
			_lastBottomScrollTS = Date().timeIntervalSince1970
			_loadData()
		}
	}
}

// MARK: Table Cell
class RestaurantCell: UITableViewCell {
	@IBOutlet weak var restaurantLabel: UILabel!
	@IBOutlet weak var foodNameLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	@IBOutlet weak var logoImage: UIImageView!
}
