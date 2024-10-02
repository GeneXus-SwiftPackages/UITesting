//
//  GXUIXCTestCase.swift
//
//
//  Created by Fabian Inthamoussu Robert on 2/10/24.
//

import XCTest

open class GXUIXCTestCase: XCTestCase {
	public lazy private(set) var app: XCUIApplication = {
		let app = XCUIApplication()
		app.launchEnvironment["GX_EXEC_ENV_TEST_MODE_ENABLED"] = true.description
		return app
	}()

	open override func setUp() {
		super.setUp()
		// In UI tests it is usually best to stop immediately when a failure occurs.
		continueAfterFailure = false
		app.launch()
		addSystemAlertsHandler()
	}
	
	func addSystemAlertsHandler() {
		// Handle system alerts by tapping the OK button
		addUIInterruptionMonitor(withDescription: "System Dialog") { (alert) -> Bool in
			let okButtonIndex = alert.buttons.count > 1 ? 1 : 0
			alert.buttons.element(boundBy: okButtonIndex).tap()
			return true
		}
	}
}
