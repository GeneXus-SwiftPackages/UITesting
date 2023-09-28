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
	
	static var currentDeviceOrientation: UIDeviceOrientation {
		var orientation = XCUIDevice.shared.orientation
		
		if orientation == .unknown || orientation.isFlat {
			if #available(iOS 13.0, *) {
#if DEBUG
				assert(!UIApplication.shared.supportsMultipleScenes, "Code assumes that multiple scenes ARE NOT supported.")
#endif
				if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
					orientation = scene.interfaceOrientation.toUIDeviceOrientation()
				}
			} else { // iOS < 13.0
				orientation = UIApplication.shared.statusBarOrientation.toUIDeviceOrientation()
			}
		}
		
		return orientation
	}
	
	static func screenshotImage(from control: XCUIScreenshotProviding, clipToSafeArea: ScreenshotClippingStyle = .none) -> UIImage {
		var screenshot = control.screenshot().image
		if clipToSafeArea != .none {
			let safeAreaInsets = AppleDeviceModel.current.safeAreaInsets(for: self.currentDeviceOrientation).scaled(by: screenshot.scale)
			let scaledSize = CGSize(width: screenshot.cgImage!.width, height: screenshot.cgImage!.height)
			let croppingRect: CGRect
			if clipToSafeArea == .safeArea {
				croppingRect = .init(x: safeAreaInsets.left, y: safeAreaInsets.top,
									 width: scaledSize.width - (safeAreaInsets.left + safeAreaInsets.right),
									 height: scaledSize.height - (safeAreaInsets.top + safeAreaInsets.bottom))
			} else if clipToSafeArea == .statusBarOnly {
				croppingRect = .init(x: 0, y: safeAreaInsets.top,
									 width: scaledSize.width,
									 height: scaledSize.height - safeAreaInsets.top)
			} else {
				fatalError("Invalid screenshot cropping style")
			}
			
			guard let cgImage = screenshot.cgImage else {
				fatalError("Unable to get screenshot image")
			}
			
			screenshot = .init(cgImage: cgImage.cropping(to: croppingRect)!, scale: screenshot.scale, orientation: screenshot.imageOrientation)
		}
		return screenshot
	}
}
