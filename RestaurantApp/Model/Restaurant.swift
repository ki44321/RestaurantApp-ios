//
//  Restaurant.swift
//  RestaurantApp
//
//  Created by Victor on 26.03.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

protocol Modelable: Decodable {}

protocol Restaurantable: Modelable {
	var restaurant: String? { get set }
	var foodName: String? { get set }
	var price: Decimal? { get set }
	var imageUrl: String? { get set }
}

struct Restaurant: Restaurantable {
	var restaurant: String?
	var foodName: String?
	var price: Decimal?
	var imageUrl: String?
	
	var formattedPrice: String {
		get {
			if let price = price {
				let formatter = NumberFormatter()
				formatter.generatesDecimalNumbers = true
				formatter.minimumFractionDigits = 2
				formatter.maximumFractionDigits = 2
				if let value = formatter.string(from: price as NSDecimalNumber) {
					return "\(value)$"
				}
			}
			
			return ""
		}
	}
}
