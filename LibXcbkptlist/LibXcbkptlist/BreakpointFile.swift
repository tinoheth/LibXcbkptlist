//
//  BreakpointFile.swift
//  Codebreaker
//
//  Created by Tino Heth on 07.02.15.
//  Copyright (c) 2015 Tino Heth. All rights reserved.
//

import Foundation

let cCreatorCode = "codebreaker.t-no.de"

public class BreakpointFile: XMLConvertible {
	private var fileBreakpoints = [String: [FileBreakpoint]]()
	private var breakpoints = Array<XMLConvertible>()

	public let lastUpdate: NSDate
	
	private let xmlDocument: NSXMLDocument

	private func extractBreakpoints(breakpointNode: NSXMLElement, ignoredCreator: String) {
		if let proxies = breakpointNode.children as? [NSXMLElement] {
			for proxy in proxies {
				let extensionID = proxy.attributeForName("BreakpointExtensionID")
				if extensionID?.stringValue == "Xcode.Breakpoint.FileBreakpoint" {
					if let breakpoint = FileBreakpoint(xmlNode: proxy) {
						//fileBreakpoints.append(breakpoint)
						if breakpoint.creatorCode != ignoredCreator {
							addFileBreakpoint(breakpoint)
						}
					}
				} else {
					breakpoints.append(proxy)
				}
				proxy.detach()
			}
		}
	}
	/**
		Standard initializer

		:param: xmlDocument

		:param: ignoredCreator Makes it easy to have a clean start by skipping breakpoints that were created in a past run - re-creation is easier than editing
	**/
	public init(xmlDocument: NSXMLDocument? = nil, changeDate: NSDate = NSDate(timeIntervalSinceReferenceDate: 0), ignoredCreator: String = cCreatorCode) {
		lastUpdate = changeDate
		if let xmlDocument = xmlDocument {
			self.xmlDocument = xmlDocument
			let xmlNode = xmlDocument.rootElement()
			if let rootChildren = xmlNode?.children as? [NSXMLElement] {
				for current in rootChildren {
					if current.name == "Breakpoints" {
						extractBreakpoints(current, ignoredCreator: ignoredCreator)
					}
				}
			}
		} else {
			self.xmlDocument = NSXMLDocument(rootElement: NSXMLElement(name: "Bucket"))
		}
	}

	public convenience init(fileURL: NSURL, ignoredCreator: String = cCreatorCode) {
		let date: NSDate
		var value: AnyObject?
		if fileURL.getResourceValue(&value, forKey: NSURLAttributeModificationDateKey, error: nil) && value is NSDate {
			date = value as! NSDate
		} else {
			date = NSDate()
		}

		if let data = NSData(contentsOfURL: fileURL), xml = NSXMLDocument(data: data, options: 0, error: nil) {
			self.init(xmlDocument: xml, changeDate: date, ignoredCreator: ignoredCreator)
		} else {
			self.init(xmlDocument: nil, changeDate: date, ignoredCreator: ignoredCreator)
		}
	}
	
	public func toXML() -> NSXMLElement? {
		return toXMLDocument().rootElement()
	}
	
	public func toXMLDocument() -> NSXMLDocument {
		let xmlNode = xmlDocument.rootElement()
		let array = NSXMLElement(name: "Breakpoints")
		xmlNode?.setChildren([array])
		let children: [NSXMLElement] = breakpoints.map { convertible in
			return convertible.toXML()!
		}
		println("Got \(children.count) breakpoints")
		array.setChildren(children)
		return xmlDocument
	}
	
	public func addFileBreakpoint(breakpoint: FileBreakpoint) {
		if var list = fileBreakpoints[breakpoint.filePath] {
			list.append(breakpoint)
		} else {
			fileBreakpoints[breakpoint.filePath] = [breakpoint]
		}
		breakpoints.append(breakpoint)
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
