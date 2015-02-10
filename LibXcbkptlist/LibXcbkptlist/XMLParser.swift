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

public class BreakpointAction: XMLConvertible {
	let actionExtensionID: String
	
	class func translate(xml: NSXMLNode) -> BreakpointAction? {
		return nil
	}
	
	init(actionExtensionID: String) {
		self.actionExtensionID = actionExtensionID
	}
	
	convenience init?(xmlNode: NSXMLElement) {
		if let extensionID = xmlNode.attributeForName("ActionExtensionID")?.stringValue {
			self.init(actionExtensionID: extensionID)
			for child in xmlNode.children as! [NSXMLNode] {
				if child.name == "ActionContent" {
					extractFromXML(child as! NSXMLElement)
				}
			}
		} else {
			self.init(actionExtensionID: "")
			return nil
		}
	}
	
	func extractFromXML(source: NSXMLElement) {
	}
	
	func fillContent(container: NSXMLElement) -> NSXMLElement {
		return container
	}
	
	func toXML() -> NSXMLElement? {
		var result = NSXMLElement(name: "BreakpointActionProxy")
		result.setAttribute("ActionExtensionID", value: actionExtensionID)
		var content = NSXMLElement(name: "ActionContent")
		result.addChild(fillContent(content))
		
		return result
	}
}

public class DebuggerCommandAction: BreakpointAction {
	var command: String
	
	init(command: String = "") {
		self.command = command
		super.init(actionExtensionID: "Xcode.BreakpointAction.DebuggerCommand")
	}
	
	override func extractFromXML(source: NSXMLElement) {
		if let content = source.attributeForName("consoleCommand")?.stringValue {
			command = content
		}
	}
	
	override func fillContent(container: NSXMLElement) -> NSXMLElement {
		container.setAttribute("consoleCommand", value: command)
		return container
	}
}

public class Breakpoint: XMLConvertible {
	public var enabled = true
	public var ignoreCount = 0
	public var continueAfterRunningActions = false
	public let breakpointExtensionID: String
	
	public var creatorCode: String?
	
	public var actions = [BreakpointAction]()
	private var children: [XMLConvertible] = []
	
	init(type: String) {
		breakpointExtensionID = type
	}
	
	public convenience init?(xmlNode: NSXMLElement) {
		if let type = xmlNode.attributeForName("BreakpointExtensionID")?.stringValue {
			self.init(type: type)
		} else {
			self.init(type: "")
			return nil
		}
		if let content = xmlNode.childAtIndex(0) as? NSXMLElement {
			if !extractFromXML(content) {
				return nil
			}
		} else {
			return nil
		}
	}

	func extractFromXML(source: NSXMLElement) -> Bool {
		return true
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
		
		for child in children {
			if let xml = child.toXML() {
				content.addChild(xml)
			}
		}
		
		var actionsElement = NSXMLElement(name: "Actions")
		
		for action in actions {
			if let xml = action.toXML() {
				content.addChild(xml)
			}
		}

		addContentTo(content)
		
		return result
	}
}

public class FileBreakpoint: Breakpoint {
	public var filePath: String = ""
	public var startingLineNumber: UInt = 0
	
	override init(type: String = "Xcode.Breakpoint.FileBreakpoint") {
		super.init(type: type)
	}
	
	public convenience init(path: String, lineNumber: UInt) {
		self.init(type: "Xcode.Breakpoint.FileBreakpoint")
		filePath = path
		startingLineNumber = lineNumber
		creatorCode = cCreatorCode
	}
	
	override func extractFromXML(source: NSXMLElement) -> Bool {
		if let fp = source.attributeForName("filePath")?.stringValue {
			filePath = fp
		} else {
			return false
		}
		let ln = source.attributeForName("startingLineNumber")
		if let s = ln?.stringValue {
			startingLineNumber = UInt(s.toInt()!)
		} else {
			return false
		}
		return true
	}

	
	override func addContentTo(content: NSXMLElement) {
		content.setAttribute("filePath", value: filePath)
		content.setAttribute("startingLineNumber", value: startingLineNumber)
		content.setAttribute("endingLineNumber", value: startingLineNumber)
		if let creator = creatorCode {
			content.setAttribute("creator", value: creator)
		}
		/* We are lucky - Xcode doesn't need that info
		content.setAttribute("timestampString", value: "444663024.303055")
		content.setAttribute("startingColumnNumber", value: 9223372036854775807)
		content.setAttribute("endingColumnNumber", value: 9223372036854775807)
		content.setAttribute("landmarkName", value: "")
		content.setAttribute("landmarkType", value: 7)
		*/
	}
}
