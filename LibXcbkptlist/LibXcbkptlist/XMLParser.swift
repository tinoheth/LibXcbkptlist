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