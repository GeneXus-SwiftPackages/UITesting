//
//  UITestingSampleAppUITestsLaunchTests.swift
//  UITestingSampleAppUITests
//
//  Created by José Echagüe on 8/14/23.
//

import XCTest
@testable import GXUITest

private func GXAssertEqualSizes(_ size1: CGSize, _ size2: CGSize, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
	if size1 != size2 {
		XCTAssertEqual(size1.width.rounded(.up), size2.width.rounded(.up), message())
		XCTAssertEqual(size1.height.rounded(.up), size2.height.rounded(.up), message())
	}
}

final class UITestingSampleAppUITestsLaunchTests: XCTestCase {

	/// App target MUST with configured as supporting all four device orientations so that tests are complete
    override class var runsForEachTargetApplicationUIConfiguration: Bool { true }

    override func setUpWithError() throws { continueAfterFailure = true }

	func testDeviceOrientation_ClippingNone() throws {
		let app = XCUIApplication()
		app.launch()
		
		let screenshot = GXUITestingHelpers.screenshotImage(from: XCUIScreen.main, clipToSafeArea: .none)
		
		let currentFrame = XCUIApplication().windows.element(boundBy: 0).frame
		
		GXAssertEqualSizes(screenshot.size, currentFrame.size, "Frame sizes don't match for orientation: \(GXUITestingHelpers.currentDeviceOrientation.gxDescription)")
	}
	
	/// This test case assumes no square devices exist (which as of 2023 has always been the case).
	func testDeviceOrientation_ClippingSafeAreaOrStatusBar() throws {
		let app = XCUIApplication()
		app.launch()
		
		[GXUITestingHelpers.ScreenshotClippingStyle.safeArea, .statusBarOnly].forEach { clippingStyle in
			let screenshot = GXUITestingHelpers.screenshotImage(from: XCUIScreen.main, clipToSafeArea: clippingStyle)
			
			let orientation = GXUITestingHelpers.currentDeviceOrientation
			if orientation.isPortrait {
				XCTAssertGreaterThan(screenshot.size.height, screenshot.size.width, "Clipping style: \(clippingStyle)")
			} else if orientation.isLandscape {
				XCTAssertGreaterThan(screenshot.size.width, screenshot.size.height, "Clipping style: \(clippingStyle)")
			} else {
				XCTFail("Unkown device orientation: \(orientation.gxDescription)")
			}
		}
	}
}

private extension UIDeviceOrientation {
	var gxDescription: String {
		switch self {
		case .portrait:
			return "portrait"
		case .portraitUpsideDown:
			return "portraitUpsideDown"
		case .landscapeLeft:
			return "landscapeLeft"
		case .landscapeRight:
			return "landscapeRight"
		case .faceUp:
			return "faceUp"
		case .faceDown:
			return "faceDown"
		case .unknown:
			fallthrough
		@unknown default:
#if DEBUG && !canImport(XCTest)
			preconditionFailure("Unknown UIDeviceOrientation value: \(self.rawValue)")
#endif
			return "Unknown orientation"
		}
	}
}
