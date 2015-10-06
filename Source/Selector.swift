//
//  Created by Tate Johnson on 14/06/2015.
//  Copyright (c) 2015 Tate Johnson. All rights reserved.
//

import Foundation

public struct Selector: Equatable, CustomStringConvertible {
	typealias Filter = (light: Light) -> Bool

	public enum Type: String {
		case All        = "all"
		case ID         = "id"
		case GroupID    = "group_id"
		case LocationID = "location_id"
		case SceneID    = "scene_id"
		case Label      = "label"
	}

	public let type: Type
	public let value: String

	public init(type: Type, value: String = "") {
		self.type = type
		self.value = value
	}

	public init?(rawSelector: String) {
		let components = rawSelector.componentsSeparatedByString(":")
		if let type = Type(rawValue: components.first ?? "") {
			if type == .All {
				self.type = type
				value = ""
			} else if let value = components.last where value.characters.count > 0 {
				self.type = type
				self.value = value
			} else {
				return nil
			}
		} else {
			return nil
		}
	}

	func toQueryStringValue() -> String {
		if type == .All {
			return type.rawValue
		} else {
			return "\(type.rawValue):\(value)"
		}
	}

	func toFilter() -> Filter {
		switch type {
		case .All:
			return { (light) in return true }
		case .ID:
			return { (light) in return light.id == self.value }
		case .GroupID:
			return { (light) in return light.group?.id == self.value }
		case .LocationID:
			return { (light) in return light.location?.id == self.value }
		case .SceneID:
			return { (light) in return true } // FIXME: Limit to lights in scene
		case .Label:
			return { (light) in return light.label == self.value }
		}
	}

	// MARK: Printable

	public var description: String {
		return "<Selector type: \"\(type)\", value: \"\(value)\">"
	}
}

public func ==(lhs: Selector, rhs: Selector) -> Bool {
	if lhs.type == .All {
		return lhs.type == rhs.type
	} else {
		return lhs.type == rhs.type && lhs.value == rhs.value
	}
}
