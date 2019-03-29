//
//  Extensions.swift
//  RestaurantApp
//
//  Created by Victor on 26.03.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import AlamofireImage

extension Collection {
	subscript (safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}

extension UIImageView {
	func load(from url: String) {
		guard let validUrl = URL(string: url) else {
			return
		}
		
		af_setImage(withURL: validUrl)
	}
}

extension UIFont {
	static var regularFont: UIFont? {
		return UIFont(name: "Helvetica Neue", size: 16.0)
	}
}
