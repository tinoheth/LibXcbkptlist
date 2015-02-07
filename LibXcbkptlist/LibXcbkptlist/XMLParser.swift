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
		var result = NSXMLNode.attributeWithName(attribute, stringValue: value.description) as NSXMLNode
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

private class BreakpointAction: XMLConvertible {
	let actionExtensionID: String
	
	init(actionExtensionID: String) {
		self.actionExtensionID = actionExtensionID
	}
	
	func actionContent() -> NSXMLElement {
		fatalError("This method must be overridden")
	}
	
	func toXML() -> NSXMLElement? {
		return nil
	}
}

public class Breakpoint: XMLConvertible {
	public var enabled = true
	public var ignoreCount = 0
	public var continueAfterRunningActions = false
	public let breakpointExtensionID: String
	private let actions = [BreakpointAction]()
	private var children: [NSXMLNode] = []
	
	init(type: String) {
		breakpointExtensionID = type
	}
	
	func addContentTo(content: NSXMLElement) {
	}
	
	public func toXML() -> NSXMLElement? {
		
		var result = NSXMLElement(name: "BreakpointProxy")
		result.setAttribute("BreakpointExtensionID", value: breakpointExtensionID)
		var content = NSXMLElement(name: "BreakpointContent")
		result.addChild(content)
		
		content.setBoolAttribute("shouldBeEnabled", value: enabled)
		content.setAttribute("ignoreCount", value: ignoreCount)
		content.setBoolAttribute("continueAfterRunningActions", value: continueAfterRunningActions)
		
		addContentTo(content)
		
		return result
	}

}

public class FileBreakpoint: Breakpoint {
	public var filePath: String
	public var startingLineNumber: UInt
	
	required public init(path: String, lineNumber: UInt) {
		filePath = path
		startingLineNumber = lineNumber
		super.init(type: "Xcode.Breakpoint.FileBreakpoint")
	}
	
	public convenience init?(xmlNode: NSXMLNode) {
		self.init(path: "", lineNumber: 0)
		if let content = xmlNode.childAtIndex(0) as? NSXMLElement {
			let fp = content.attributeForName("filePath")
			filePath = fp?.stringValue ?? ""
			let ln = content.attributeForName("startingLineNumber")
			if let s = ln?.stringValue {
				startingLineNumber = UInt(s.toInt()!)
			} else {
				return nil
			}
		} else {
			return nil
		}
	}
	
	let cCreatorCode = "codebreaker.t-no.de"
	
	override func addContentTo(content: NSXMLElement) {
		content.setAttribute("filePath", value: filePath)
		content.setAttribute("startingLineNumber", value: startingLineNumber)
		content.setAttribute("endingLineNumber", value: startingLineNumber)
		content.setAttribute("creator", value: cCreatorCode)
		
		/* We are lucky - Xcode doesn't need that info
		content.setAttribute("timestampString", value: "444663024.303055")
		content.setAttribute("startingColumnNumber", value: 9223372036854775807)
		content.setAttribute("endingColumnNumber", value: 9223372036854775807)
		content.setAttribute("landmarkName", value: "")
		content.setAttribute("landmarkType", value: 7)
		*/
	}
}
