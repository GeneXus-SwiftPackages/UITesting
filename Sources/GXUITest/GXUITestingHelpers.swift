//
//  GXUITestingHelpers.swift
//  
//
//  Created by José Echagüe on 8/14/23.
//

import Foundation
import XCTest

internal struct GXUITestingHelpers {
	enum ScreenshotClippingStyle {
		case none
		case statusBarOnly
		case safeArea
	}
	
	static func screenshotImage(from control: XCUIScreenshotProviding, clipToSafeArea: ScreenshotClippingStyle = .none) -> UIImage {
		var screenshot = control.screenshot().image
		lazy var sizeInPixels = screenshot.size.scaled(by: screenshot.scale)
		var croppingRectInPixels: CGRect = {
			switch clipToSafeArea {
			case .none:
				return .zero
			case .statusBarOnly:
				let scaledStatusBarHeight = XCUIApplication.gxAppStatusBarFrame.size.scaled(by: screenshot.scale).height
				return .init(x: 0, y: scaledStatusBarHeight,
							 width: sizeInPixels.width,
							 height: sizeInPixels.height - scaledStatusBarHeight)
			case .safeArea:
				let scaledSafeAreaInsets = XCUIApplication.gxAppSafeAreaInsets.scaled(by: screenshot.scale)
				return .init(x: scaledSafeAreaInsets.left, y: scaledSafeAreaInsets.top,
							 width: sizeInPixels.width - (scaledSafeAreaInsets.left + scaledSafeAreaInsets.right),
							 height: sizeInPixels.height - (scaledSafeAreaInsets.top + scaledSafeAreaInsets.bottom))
			}
		}()
		if !croppingRectInPixels.isEmpty {
			switch screenshot.imageOrientation {
			case .up:
				break
			case .right:
				croppingRectInPixels = .init(x: croppingRectInPixels.origin.y,
											 y: sizeInPixels.width - croppingRectInPixels.maxX,
											 width: croppingRectInPixels.height,
											 height: croppingRectInPixels.width)
			case .left:
				croppingRectInPixels = .init(x: sizeInPixels.height - croppingRectInPixels.maxY,
											 y: croppingRectInPixels.origin.x,
											 width: croppingRectInPixels.height,
											 height: croppingRectInPixels.width)
			default:
				fatalError("Invalid screenshot image orientation: \(screenshot.imageOrientation)")
			}
			guard let croppedImage = screenshot.cgImage?.cropping(to: croppingRectInPixels) else {
				fatalError("Unable to crop screenshot image")
			}
			screenshot = .init(cgImage: croppedImage, scale: screenshot.scale, orientation: screenshot.imageOrientation)
		}
		return screenshot
	}
	
	static func gxData(from value: Any?, encoding: String.Encoding = .utf8) -> [String: Any]? {
		guard let valueString = value as? String else {
			return nil
		}
		guard let valueData = valueString.data(using: encoding) else {
			XCTFail("Could not obtain data from '\(valueString)' using encoding '\(encoding)'")
			return nil
		}
		guard let jsonObj = try? JSONSerialization.jsonObject(with: valueData) as? [String: Any] else {
			return nil
		}
		return jsonObj["gx.data"] as? [String: Any]
	}
}


internal extension XCUIApplication {
	static var gxAppSafeAreaInsets: UIEdgeInsets {
		guard let safeAreaInsets = gxAppGXData["safeAreaInsets"] as? [String: Any],
			  let top = safeAreaInsets["top"] as? CGFloat,
			  let left = safeAreaInsets["left"] as? CGFloat,
			  let bottom = safeAreaInsets["bottom"] as? CGFloat,
			  let right = safeAreaInsets["right"] as? CGFloat else {
			XCTFail("Could not retreive GX app data value for safeAreaInsets")
			return .zero
		}
		return .init(top: top, left: left, bottom: bottom, right: right)
	}
	
	static var gxAppStatusBarFrame: CGRect {
		guard let statusBarFrame = gxAppGXData["statusBarFrame"] as? [String: Any],
			  let x = statusBarFrame["x"] as? CGFloat,
			  let y = statusBarFrame["y"] as? CGFloat,
			  let width = statusBarFrame["width"] as? CGFloat,
			  let height = statusBarFrame["height"] as? CGFloat else {
			XCTFail("Could not retreive GX app data value for statusBarFrame")
			return .zero
		}
		return .init(x: x, y: y, width: width, height: height)
	}
	
	private static var gxAppGXData: [String: Any] {
		guard let gxwindowValue = XCUIApplication().windows.firstMatch.value,
			  let gxData = GXUITestingHelpers.gxData(from: gxwindowValue) else {
			XCTFail("Could not retreive GX app data")
			return [:]
		}
		return gxData
	}
}

internal enum GXSwipeDirection: Int, CustomStringConvertible {
	case up = 1
	case down = 2
	case left = 3
	case right = 4
	
	var description: String {
		switch self {
		case .up: return "up"
		case .down: return "down"
		case .left: return "left"
		case .right: return "right"
		}
	}
}
