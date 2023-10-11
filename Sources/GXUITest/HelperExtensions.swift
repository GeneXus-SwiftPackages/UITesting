//
//  HelperExtensions.swift
//  
//
//  Created by José Echagüe on 8/14/23.
//

import Foundation
import XCTest

internal extension XCUIElement {

	private func hasText() -> Bool {
		if let placeholder = self.placeholderValue {
			if let value = self.value as? String {
				return value != placeholder
			}
			else {
				return false
			}
		}
		else {
			return self.value != nil
		}
	}

	private func hasFocus() -> Bool {
		return self.value(forKey: "hasKeyboardFocus") as? Bool ?? false
	}

	private func isKeyboardVisible() -> Bool {
		XCUIApplication().keyboards.count > 0
	}

	func clearText() {
		if !self.hasFocus() {
			self.tap()
		}
		
		if self.hasText() {
			let clearButton = self.descendants(matching: .button).matching(identifier: "Clear text")
			if clearButton.count > 0 {
				clearButton.element(boundBy: 0).tap()
				self.tap()
				return
			}

			let menuItems = XCUIApplication().descendants(matching: .menuItem)
			let menuItemQuery = menuItems.matching(identifier: "Select All")

			if !(menuItems.count > 0) {
				self.press(forDuration: 1.5) // tap and hold to select all
				_waitMilliseconds(500)
			}
			
			if menuItemQuery.count > 0 {
				menuItemQuery.element(boundBy: 0).tap()
			}

			if !isKeyboardVisible() {
				self.tap()
			}
			self.typeText(XCUIKeyboardKey.delete.rawValue)
		}
	}
}

internal extension CGImage {
	var data: Data? {
		guard let mutableData = CFDataCreateMutable(nil, 0),
			  let destination = CGImageDestinationCreateWithData(mutableData, "public.png" as CFString, 1, nil) else { return nil }
		CGImageDestinationAddImage(destination, self, nil)
		guard CGImageDestinationFinalize(destination) else { return nil }
		return mutableData as Data
	}
}

private extension UIImage.Orientation {
	var isLandscape: Bool {
		switch self {
		case .left, .right, .leftMirrored, .rightMirrored:
			return true
			
		default:
			return false
		}
	}
}

internal extension UIImage {
	func rotatedPngData() -> Data? {
		guard self.imageOrientation != .up else { return self.pngData() }
		
		guard let cgImage else { return nil }
		
		var size = self.imageOrientation.isLandscape ? .init(width: self.size.height, height: self.size.width) : self.size
		size = size.scaled(by: 1 / self.scale)
		
		let renderer = UIGraphicsImageRenderer(size: size, format: self.imageRendererFormat)
		return renderer.pngData { ctx in
			ctx.cgContext.draw(cgImage, in: .init(origin: .zero, size: size))
		}
	}
}

internal extension UIEdgeInsets {
	func scaled(by scale: CGFloat) -> UIEdgeInsets {
		UIEdgeInsets.init(top: self.top * scale, left: self.left * scale, bottom: self.bottom * scale, right: self.right * scale)
	}
}

internal extension CGSize {
	func scaled(by scale: CGFloat) -> CGSize {
		CGSize.init(width: self.width * scale, height: self.height * scale)
	}
}

internal extension UIInterfaceOrientation {
	func toUIDeviceOrientation() -> UIDeviceOrientation {
		switch self {
		case .portrait:
			return .portrait
		case .portraitUpsideDown:
			return .portraitUpsideDown
		case .landscapeLeft:
			return .landscapeLeft
		case .landscapeRight:
			return .landscapeRight
		default:
			#if DEBUG
			assertionFailure("Unknowen device orientation: \(self)")
			#endif
			return .unknown
		}
	}
}
