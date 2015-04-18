//
//  Breakpoint.swift
//  Codebreaker
//
//  Created by Tino Heth on 18.04.15.
//  Copyright (c) 2015 Tino Heth. All rights reserved.
//

import Foundation

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
		content.addChild(actionsElement)
		for action in actions {
			if let xml = action.toXML() {
				actionsElement.addChild(xml)
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

	public func description() -> NSString {
		return "Breakpoint at \(self.filePath), line \(self.startingLineNumber)"
	}

	override func extractFromXML(source: NSXMLElement) -> Bool {
		if let creator = source.attributeForName("creator")?.stringValue {
			creatorCode = creator
		}
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
