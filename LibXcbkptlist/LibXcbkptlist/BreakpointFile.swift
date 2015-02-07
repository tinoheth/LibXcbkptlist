//
//  BreakpointFile.swift
//  Codebreaker
//
//  Created by Tino Heth on 07.02.15.
//  Copyright (c) 2015 Tino Heth. All rights reserved.
//

import Foundation

public class BreakpointFile: XMLConvertible {
	private var fileBreakpoints = [String: [FileBreakpoint]]()
	private var breakpoints = Array<XMLConvertible>()
	
	private let xmlDocument: NSXMLDocument
	
	public init(xmlDocument: NSXMLDocument) {
		self.xmlDocument = xmlDocument
		let xmlNode = xmlDocument.rootElement()
		if let array = xmlNode?.childAtIndex(0) as? NSXMLElement {
			for proxy in (array.children as [NSXMLElement]) {
				let extensionID = proxy.attributeForName("BreakpointExtensionID")
				if extensionID?.stringValue == "Xcode.Breakpoint.FileBreakpoint" {
					if let breakpoint = FileBreakpoint(xmlNode: proxy) {
						//fileBreakpoints.append(breakpoint)
						addFileBreakpoint(breakpoint)
						breakpoints.append(breakpoint)
					}
				} else {
					breakpoints.append(proxy)
				}
				proxy.detach()
			}
		}
	}
	
	public func toXML() -> NSXMLElement? {
		return toXMLDocument().rootElement()
	}
	
	public func toXMLDocument() -> NSXMLDocument {
		let xmlNode = xmlDocument.rootElement()
		if let array = xmlNode?.childAtIndex(0) as? NSXMLElement {
			let children: [NSXMLElement] = breakpoints.map { convertible in
				return convertible.toXML()!
			}
			array.setChildren(children)
		}
		return xmlDocument
	}
	
	public func addFileBreakpoint(br: FileBreakpoint) -> Self {
		if var list = fileBreakpoints[br.filePath] {
			list.append(br)
		} else {
			fileBreakpoints[br.filePath] = [br]
		}
		breakpoints.append(br)
		return self
	}
	
	public func deleteBreakpoint(br: Breakpoint) -> Self {
		func excludeBreakpoint(current: XMLConvertible) -> Bool {
			if let check = current as? Breakpoint {
				return br !== check
			} else {
				return true
			}
		}
		
		if let fb = br as? FileBreakpoint {
			if let list = fileBreakpoints[fb.filePath] {
				//fileBreakpoints[fb.filePath] = list.filter(excludeBreakpoint)
				var next = [FileBreakpoint]()
				for current in list {
					if current !== fb {
						next.append(current)
					}
				}
				if next.count > 0 {
					fileBreakpoints[fb.filePath] = next
				} else {
					fileBreakpoints.removeValueForKey(fb.filePath)
				}
			}
		}
		breakpoints = breakpoints.filter(excludeBreakpoint)
		
		return self
	}
	
	public func deleteAllBreakpoints() {
		fileBreakpoints.removeAll(keepCapacity: false)
		breakpoints.removeAll(keepCapacity: false)
	}
	
	public func fileBreakpointsForPath(path: String?) -> [FileBreakpoint] {
		if let path = path {
			if let result = fileBreakpoints[path] {
				return result
			} else {
				return []
			}
		} else {
			return []
		}
	}
	
	public func registeredFiles() -> [String] {
		return fileBreakpoints.keys.array
	}
}
