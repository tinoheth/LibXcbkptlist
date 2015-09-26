//
//  BreakpointAction.swift
//  Codebreaker
//
//  Created by Tino Heth on 18.04.15.
//  Copyright (c) 2015 Tino Heth. All rights reserved.
//

import Foundation

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
			for child in xmlNode.children! {
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
		let result = NSXMLElement(name: "BreakpointActionProxy")
		result.setAttribute("ActionExtensionID", value: actionExtensionID)
		let content = NSXMLElement(name: "ActionContent")
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
