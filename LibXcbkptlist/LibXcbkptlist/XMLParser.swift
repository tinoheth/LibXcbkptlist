//
//  XMLParser.swift
//  LibXcbkptlist
//
//  Created by Tino Heth on 04.01.15.
//  Copyright (c) 2015 Tino Heth. All rights reserved.
//

import Foundation

public enum ParserResult {
	case success(data: NSXMLDocument)
	case error(error: NSError?)
}

public func parse(url: NSURL) -> ParserResult {
	var err: NSError?
	let result = NSXMLDocument(contentsOfURL: url, options: 0, error: &err)
	if let result = result {
		return ParserResult.success(data: result)
	} else {
		return ParserResult.error(error: err)
	}
}

extension NSXMLElement {
	func setBoolAttribute(attribute: String, value: Bool) -> Self {
		var stringValue: String
		if value {
			stringValue = "Yes"
		} else {
			stringValue = "No"
		}
		return setAttribute(attribute, value: stringValue)
	}
	
	func setAttribute(attribute: String, value: AnyObject) -> Self {
		var result = NSXMLNode.attributeWithName(attribute, stringValue: value.description) as! NSXMLNode
		self.addAttribute(result)
		return self
	}
}

protocol XMLConvertible {
	func toXML() -> NSXMLElement?
}

extension NSXMLElement: XMLConvertible {
	func toXML() -> NSXMLElement? {
		return self
	}
}