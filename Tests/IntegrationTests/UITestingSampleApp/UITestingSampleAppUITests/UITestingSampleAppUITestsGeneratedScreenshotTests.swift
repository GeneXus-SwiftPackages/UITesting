//
//  UITestingSampleAppUITestsGeneratedScreenshotTests.swift
//
//
//  Created by José Echagüe on 10/10/23.
//

import XCTest

@testable import GXUITest

final class UITestingSampleAppUITestsGeneratedScreenshotTests: XCTestCase {
	
	override class var runsForEachTargetApplicationUIConfiguration: Bool { false }
	
	func testDeviceOrientation_ShouldBePreserved() throws {
		let app = XCUIApplication()
		app.launch()
		
		XCUIDevice.shared.orientation = .landscapeLeft
		
		let screenshot = GXUITestingHelpers.screenshotImage(from: XCUIScreen.main, clipToSafeArea: .none)
		
		let pngData = try XCTUnwrap(screenshot.rotatedPngData())
		let reconstructedImage = try XCTUnwrap(UIImage(data: pngData))
		
		// Height and width are swapped because reconstructed image always has orientation = .up
		XCTAssertEqual(screenshot.size.height, reconstructedImage.size.width, accuracy: 0.5)
		XCTAssertEqual(screenshot.size.width, reconstructedImage.size.height, accuracy: 0.5)
	}
}
