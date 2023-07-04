//
//  GXUITestingAPI.swift
//

import XCTest

@_exported import Foundation
@_exported import GXStandardClasses
import GXObjectsModel

// MARK: - GeneXus UI Test object

public class SdtUITestSD {
	
	public init() { }
	
	// MARK: Configuration variables
	
	public static var visualTestingServer: String = ""
	
	// MARK: EO implementation

	public func back() {
		runActivity(forAction: "Tap", target: nil, inContext: nil) {
			// Note: back button is (generally...) the first button in the navigation bar
			let findBackButton: () -> XCUIElement? = { () in
				let navBars = XCUIApplication().navigationBars
				if navBars.count > 0 {
					let navButtons = navBars.element(boundBy: 0).buttons
					if navButtons.count > 0 {
						return navButtons.element(boundBy: 0)
					}
				}
				return nil
			}

			if let backButton = findBackButton() {
				if backButton.isHittable {
					backButton.tap()
				}
				else {
					// Hack: sometimes a button is identifing as hittable, so send a tap directly to the middle of it
					backButton.coordinate(withNormalizedOffset: CGVector(dx:0.5, dy:0.5)).tap()
				}
			}
			else {
				XCTAssert(false, "Could not find back button")
			}
		}
	}

	public func tap(_ target: String, _ context: String? = nil) {
		runActivity(forAction: "Tap", target: target, inContext: context) {
			tapElement(withName: target, context: context)
		}
	}

	public func longtap(_ target: String, _ context: String? = nil) {
		runActivity(forAction: "LongTap", target: target, inContext: context) {
			if let control = _findControl(name: target, context: context, elementTypes: _tapableElementTypes) {
				control.press(forDuration: 1.0)
			}
			else {
				XCTAssert(false, "Could not find control with name '\(target)'")
			}
		}
	}

	public func doubletap(_ target: String, _ context: String? = nil) {
		runActivity(forAction: "DoubleTap", target: target, inContext: context) {
			if let control = _findControl(name: target, context: context, elementTypes: _tapableElementTypes) {
				control.doubleTap()
			}
			else {
				XCTAssert(false, "Could not find control with name '\(target)'")
			}
		}
	}

	public func fill(_ controlName: String, _ value: String, _ context: String? = nil) {
		runActivity(forAction: "Fill", target: controlName, inContext: context) {
			if let control = _findControl(name: controlName, context: context, elementTypes: _textInputElementTypes) {
				control.clearText()
				control.typeText(value)
			}
			else {
				XCTAssert(false, "Could not find control with name '\(controlName)'")
			}
		}
	}

	public func pickdate(_ controlName: String, _ year: Int, _ month: Int, _ day: Int, _ context: String? = nil) {
		runActivity(forAction: "PickDate", target: controlName, inContext: context) {
			if useNewDateTimePicker() {
				guard let datePicker = findDatePicker(name: controlName, context: context) else {
					XCTAssert(false, "Could not find date picker for control '\(controlName)'")
					return
				}
				pickDate(datePicker, year: year, month: month, day: day)
				self.tapOutside(datePicker)
			}
			else {	// !useNewDateTimePicker()
				guard let dateField = _findControl(name: controlName, context: context) else {
					XCTAssert(false, "Could not find control with name '\(controlName)'")
					return
				}
				dateField.tap()
				let datePickers = XCUIApplication().descendants(matching: .datePicker)
				if datePickers.count > 0 {
					pickDate(datePickers.element(boundBy: datePickers.count-1), year: year, month: month, day: day)
				}
				else {
					XCTAssert(false, "Could not find date picker for control '\(controlName)'")
				}
			}
		}	}

	public func pickdatetime(_ controlName: String, _ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minutes: Int, _ context: String? = nil) {
		runActivity(forAction: "PickDateTime", target: controlName, inContext: context) {
			if useNewDateTimePicker() {
				guard let datePicker = findDatePicker(name: controlName, context: context) else {
					XCTAssert(false, "Could not find date picker for control '\(controlName)'")
					return
				}
				pickDate(datePicker, year: year, month: month, day: day)
				pickTime(datePicker, hour: hour, minute: minutes)
				self.tapAtCoordinate(x: 0, y: 0)
			}
			else { // !useNewDateTimePicker()
				guard let dateTimeField = _findControl(name: controlName, context: context) else {
					XCTAssert(false, "Could not find control with name '\(controlName)'")
					return
				}
				dateTimeField.tap()

				let dateItem = XCUIApplication().tables.cells.element(boundBy: 0)
				dateItem.tap()

				let datePickers = XCUIApplication().descendants(matching: .datePicker)
				if datePickers.count > 0 {
					pickDate(datePickers.element(boundBy: datePickers.count-1), year: year, month: month, day: day)
				}
				else {
					XCTAssert(false, "Could not find date picker for control '\(controlName)'")
				}

				let timeItem = XCUIApplication().tables.cells.element(boundBy: 1)
				timeItem.tap()

				let timePickers = XCUIApplication().descendants(matching: .datePicker)
				if timePickers.count > 0 {
					pickTime(timePickers.element(boundBy: timePickers.count-1), hour: hour, minute: minutes)
				}
				else {
					XCTAssert(false, "Could not find time picker for control '\(controlName)'")
				}

				tapNavigationBarDoneButton()
			}
		}
	}

	public func picktime(_ controlName: String, _ hour: Int, _ minutes: Int, _ context: String? = nil) {
		runActivity(forAction: "PickTime", target: controlName, inContext: context) {
			if useNewDateTimePicker() {
				guard let datePicker = findDatePicker(name: controlName, context: context) else {
					XCTAssert(false, "Could not find date picker for control '\(controlName)'")
					return
				}
				pickTime(datePicker, hour: hour, minute: minutes)
				self.tapAtCoordinate(x: 0, y: 0)
			}
			else {	// !useNewDateTimePicker()
				guard let timeField = _findControl(name: controlName, context: context) else {
					XCTAssert(false, "Could not find control with name '\(controlName)'")
					return
				}
				timeField.tap()

				let timePickers = XCUIApplication().descendants(matching: .datePicker)
				if timePickers.count > 0 {
					pickTime(timePickers.element(boundBy: timePickers.count-1), hour: hour, minute: minutes)
				}
				else {
					XCTAssert(false, "Could not find time picker for control '\(controlName)'")
				}
			}
		}
	}

	public func selectvalue(_ controlName: String, _ value: String, _ context: String? = nil) {
		runActivity(forAction: "SelectValue", target: controlName, inContext: context) {
			if let control = _findControl(name: controlName, context: context, elementTypes: _allElementTypes) {
				if (control.elementType == .segmentedControl) {
					// radio button
					let radioContext = context == nil ? controlName : "\(context!).\(controlName)"
					tapElement(withName: value, context: radioContext)
				}
				else {
					tapElement(withName: controlName, context: context)
					tapElement(withName: value)
				}
			}
		}
	}

	public func swipe(_ direction: Int, _ controlName: String? = nil, _ context: String? = nil) {
		let strDirection: String = {
			switch direction {
			case 1: return "up"
			case 2: return "down"
			case 3: return "left"
			case 4: return "right"
			default: return "left"
			}
		}()
		runActivity(forAction: "Swipe \(strDirection)", target: controlName, inContext: context) {
			let targetControlName = controlName == nil ? "maintable" : controlName!;
			if let control = _findControl(name: targetControlName, context: context) {
				switch (strDirection.lowercased()) {
				case "up":
					control.swipeUp()
				case "down":
					control.swipeDown()
				case "left":
					control.swipeLeft()
				case "right":
					control.swipeRight()
				default:
					XCTAssert(false, "Unknown swipe direction: \(direction)")
				}
			}
			else {
				XCTAssert(false, "Could not find control with name '\(targetControlName)'")
			}
		}
	}

	public func wait(_ milliseconds: Int) {
		runActivity(forAction: "Wait", target: nil, inContext: nil) {
			_waitMilliseconds(milliseconds)
		}
	}

	public func verifytext(_ text: String, _ expected: Bool = true, _ context: String? = nil) {
		runActivity(forAction: "VerifyText", target: text, inContext: context) {
			let control = _findControl(name: text, context: context)
			let found = control != nil
			XCTAssert(found == expected, "Text '\(text)' was \(expected ? "" : "not ")expected but did \(found ? "" : "not ")find it")
		}
	}

	public func verifygridrowscount(_ controlName: String, _ count: Int, _ expected: Bool = true, _ context: String? = nil) {
		runActivity(forAction: "VerifyGridRowsCount", target: controlName, inContext: context) {
			if let control = _findControl(name: controlName, context: context, elementTypes: _allElementTypes) {
				let rows = control.children(matching: .cell).matching(NSPredicate(format: "identifier != 'GXLoadingCell'")).count
				XCTAssert(expected ? rows == count : rows != count, "Grid '\(controlName)' should \(expected ? "" : "not ")have \(count) rows, found \(rows).")
			}
			else {
				XCTAssert(false, "Could not find grid with name '\(controlName)'")
			}
		}
	}

	public func verifycheckbox(_ controlName: String, _ value: Bool, _ context: String? = nil) {
		runActivity(forAction: "VerifyCheckbox", target: controlName, inContext: context) {
			if let control = _findControl(name: controlName, context: context, elementTypes: _allElementTypes) {
				let selected = control.isSelected;
				XCTAssert(selected == value, "Checkbox '\(controlName)' was expected to be \(value ? "un" : "")selected but is not.")
			}
			else {
				XCTAssert(false, "Could not find grid with name '\(controlName)'")
			}
		}
	}

	public func getcheckboxvalue(_ controlName: String, _ context: String? = nil) -> Bool {
		var selected = false
		runActivity(forAction: "GetCheckboxValue", target: controlName, inContext: context) {
			guard let control = _findControl(name: controlName, context: context, elementTypes: _allElementTypes) else {
				XCTAssert(false, "Could not find control with name '\(controlName)'")
				return
			}
			selected = control.isSelected;
		}
		return selected
	}

	public func verifycontrolvalue(_ controlName: String, _ value: String, _ expected: Bool = true, _ context: String? = nil) {
		runActivity(forAction: "VerifyControlValue", target: controlName, inContext: context) {
			if let control = _findControl(name: controlName, context: context, elementTypes: _allElementTypes),
			   let controlValueString = controlValueString(control: control) {

				let result = isEqualTextValue(controlValueString, to: value)
				XCTAssert(result == expected, "Value '\(controlValueString)' \(expected ? "does not match expected" : "matches not expected") value '\(value)'")
			}
			else {
				XCTAssert(false, "Could not find control with name '\(controlName)'")
			}
		}
	}

	public func verifycontrolenabled( _ controlName: String, _ expected: Bool = true, _ context: String? = nil) {
		runActivity(forAction: "VerifyControlEnabled", target: controlName, inContext: context) {
			// TODO: control.isEnabled is returning 'true' even when the control is no enabled
//			if let control = _findControl(name: controlName, context: context, elementTypes: _allElementTypes) {
//				let enabled = control.isEnabled
//				XCTAssert(enabled == expected, "Control '\(controlName)' should \(expected ? "" : "not ")be enabled but it was\(enabled ? "" : " not").")
//			}
//			else {
//				XCTAssert(false, "Could not find control with name '\(controlName)'")
//			}
		}
	}

	public func verifymsg(_ text: String, _ expected: Bool = true) {
		runActivity(forAction: "VerifyMsg", target: text, inContext: nil) {
			let alertsQuery = XCUIApplication().descendants(matching: .alert)
			var found = alertsQuery.matching(identifier: text).count > 0 || alertsQuery.descendants(matching: .staticText).matching(identifier: text).count > 0
			if !found, let fullText = alertMessageFullText(from: alertsQuery){
				// GeneXus' msg function may split the text if it has several lines
				found = isEqualTextValue(fullText, to: text)
			}
			XCTAssert(found == expected, "Alert with test '\(text)' was \(expected ? "" : "not ")expected but did \(found ? "" : "not ")find it")
		}
	}

	public func verifycontrolvisible(_ controlName: String, _ expected: Bool = true, _ context: String? = nil) {
		runActivity(forAction: "VerifyControlVisible", target: controlName, inContext: context) {
			if let control = _findControl(name: controlName, context: context, elementTypes: _allElementTypes) {
				let visible = control.isHittable
				XCTAssert(visible == expected, "Control '\(controlName)' should \(expected ? "" : "not ")be enabled but it was\(visible ? "" : " not").")
			}
			else {
				XCTAssert(!expected, "Could not find control with name '\(controlName)'")
			}
		}
	}

	public func iscontrolvisible( _ controlName: String, _ context: String? = nil) -> Bool {
		var visible = false
		runActivity(forAction: "IsControlVisible", target: controlName, inContext: context){
			if let control = _findControl(name: controlName, context: context, elementTypes: _allElementTypes) {
				visible = control.isHittable
			}
			else {
				visible = false
			}
		}
		return visible
	}

	public func iscontrolenabled( _ controlName: String, _ context: String? = nil) -> Bool {
		var enabled = false
		runActivity(forAction: "IsControlEnabled", target: controlName, inContext: context){
			guard let control = _findControl(name: controlName, context: context, elementTypes: _allElementTypes) else {
				XCTAssert(false, "Could not find control with name '\(controlName)'")
				return
			}
			
			// TODO: control.isEnabled is returning 'true' even when the control is no enabled, using same implementation as "is visible"
			//enabled = control.isEnabled
			enabled = control.isHittable
		}
		return enabled
	}

	public func verifyscreenshot( _ reference: String, _ controlName: String? = nil, _ context: String? = nil, testFile: String = #file ) {
		let findElement: () -> XCUIScreenshotProviding? = {
			if let controlName = controlName {
				return _findControl(name: controlName, context: context)
			}
			else {
				//return XCUIApplication().windows.firstMatch
				return XCUIScreen.main
			}
		}

		// wait for app to idle
		_waitMilliseconds(1000)

		runActivity(forAction: "VerifyScreenshot", target: controlName, inContext: context) {
			if let control = findElement() {
				
				let bundleId = Bundle.main.bundleIdentifier!
				let testName = (testFile as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
				
				do {
					let visualTestingProvider = VisualTestingProvider(projectCode: bundleId, testName: testName, reference: reference)
					
					let capturedImage = GXUITestingHelpers.screenshotImage(from: control, clipToSafeArea: controlName != nil ? .none : .safeArea)
					if let expectedImage = try visualTestingProvider.getReferenceImage() {
						let expected = expectedImage.cgImage?.data
						let captured = capturedImage.cgImage?.data
						
						if let expected = expected, let captured = captured, expected == captured {
							// all fine, raw bytes matched
						}
						else {
							guard let capturedCIImage = capturedImage.ciImage ?? CIImage(image: capturedImage) else {
								XCTFail("Unable to obtain CIImage from captured screenshot")
								return
							}
							do {
								if try expectedImage.perceptuallyCompare(to: capturedCIImage) {
									// Perceptual comparison passed
								} else {
									try? visualTestingProvider.saveImageWithDifference(image: capturedImage)
									XCTAssert(false, "Screenshots do not match for image reference '\(reference)'")
								}
							} catch GXUITestError.runtimeError(let errorMessage) {
								XCTFail(errorMessage)
							}
						}
					}
					else {
						// did not get image, send new reference image and make the test fail
						try? visualTestingProvider.saveReferenceImage(image: capturedImage)
						XCTAssert(false, "Server image not available for image reference '\(reference)'")
					}
				}
				catch {
					XCTAssert(false, "Unexpected error getting server image for image reference '\(reference)'")
					return
				}
			}
			else {
				if let controlName = controlName {
					XCTAssert(false, "Could not find control with name '\(controlName)'")
				}
				else {
					XCTAssert(false, "Could not find applications main screen")
				}
			}
		}
	}

	public func isshowingmessage() -> Bool {
		var found = false
		runActivity(forAction: "IsShowingMessage", target: nil, inContext: nil) {
			let alertsQuery = XCUIApplication().descendants(matching: .alert)
			found = alertsQuery.count > 0
		}
		return found
	}

	public func getcontrolvalue( _ controlName: String, _ context: String? = nil) -> String {
		var value: String?
		runActivity(forAction: "GetControlValue", target: controlName, inContext: context) {
			guard let control = _findControl(name: controlName, context: context, elementTypes: _allElementTypes) else {
				XCTAssert(false, "Could not find control with name '\(controlName)'")
				return
			}
			switch control.elementType {
			case .staticText:
				value = control.label
			default:
				value = control.value as? String
			}
		}
		return value ?? ""
	}

	public func getmessagetext() -> String {
		var messageText :String?
		runActivity(forAction: "GetMessageText", target: nil, inContext: nil) {
			let alertsQuery = XCUIApplication().descendants(matching: .alert)
			guard alertsQuery.count > 0 else {
				XCTAssert(false, "No alert message found")
				return
			}
			messageText = alertMessageFullText(from: alertsQuery)
		}
		return messageText ?? ""
	}

	public func verifycondition(_ value: Bool, _ message: String? = nil) {
		runActivity(forAction: "VerifyCondition", target: nil, inContext: nil) {
			XCTAssert(value, message ?? "")
		}
	}

	public func getgridrowscount(_ controlName: String, _ context: String? = nil) -> Int {
		var rows = 0
		runActivity(forAction: "GetGridRowsCount", target: controlName, inContext: context) {
			guard let control = _findControl(name: controlName, context: context, elementTypes: _allElementTypes) else {
				XCTAssert(false, "Could not find control with name '\(controlName)'")
				return
			}
			rows = control.children(matching: .cell).count
		}
		return rows
	}

	// MARK: System Alerts
	
	public func tapsystemalertifshown(_ buttonType: Int, _ alertType: String? = nil) {
		runActivity(forAction: "TapSystemAlertIfShown", target: "SystemAlert", inContext: nil) {
			
			guard
				let alert = systemAlertIfShown(ofType: alertType)
			else {
				// System alert not found test passed
				return
			}
			
			guard
				let buttonToTap = systemButtonIndexToTap(buttonType),
				alert.buttons.count > buttonToTap
			else {
				XCTAssert(false, "Specified button not found in \(alertType ?? "alert")")
				return
			}
			
			alert.buttons.element(boundBy: buttonToTap).tap()
		}
	}
	
	private func systemAlertIfShown(ofType alertType: String?) -> XCUIElement? {
		let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
		let springboardAlerts = springboard.alerts
		
		guard springboardAlerts.count > 0 else { return nil }
		
		if let alertType = alertType {
			var alert: XCUIElement? = nil
			for i in 0..<springboardAlerts.count {
				alert = springboardAlerts.element(boundBy: i)
				if isRequiredSystemAlert(alert!, ofType: alertType) {
					break
				}
			}
			return alert
		}
		else {
			return springboardAlerts.element(boundBy: 0)
		}
	}
	
	private func isRequiredSystemAlert(_ alert: XCUIElement, ofType alertType: String) -> Bool {
		let possibleMessagesByAlertType: Dictionary<String, [String]> = [
			"Bluetooth"  : ["Bluetooth","bluetooth"],
			"Calendar"   : ["Calendar", "calendario"],
			"Camera"     : ["Would Like to Access Your Camera","quiere acceder a tu camara"],
			"Contacts"   : ["Would Like to Access Your Contacts","quiere acceder a tus contactos"],
			"Location"   : ["use your location", "utilizar tu ubicación"],
			"Microphone" : ["Access the Microphone","quiere acceder al micrófono"],
			"Photos"     : ["Would Like to Acces Your Photos","quiere acceder a tus fotos"]
		]
		
		guard let possibleTexts = possibleMessagesByAlertType[alertType] else {
			return false
		}
		
		return possibleTexts
			.filter { searchString in alert.label.contains(searchString) }
			.count > 0
	}
	
	private enum SystemAlertButton: Int {
		case alwaysAllow = 5
		case whileUsingAppAllow = 4
		case onceAllow = 3
		case ok = 2
		case dontAllow = 1
	}
	
	private func systemButtonIndexToTap(_ incomingIndex: Int) ->  Int? {
		var buttonIndex: Int?
		
		if let alertButtonType = SystemAlertButton(rawValue: incomingIndex) {
			switch alertButtonType {
			case .alwaysAllow:
				buttonIndex = 2
			case .whileUsingAppAllow:
				buttonIndex = 1
			case .onceAllow:
				buttonIndex = 0
			case .ok:
				buttonIndex = 1
			case .dontAllow:
				buttonIndex = 0
			}
		}
		
		return buttonIndex
		
	}

	// MARK: Private methods

	private func runActivity(forAction action: String, target: String?, inContext context: String?, _ activityBlock: () -> Void) {
		let activityDescription = { () -> String in
			let baseDescription = target == nil ? action : "\(action) '\(target!)'"
			return context == nil ? baseDescription : "\(baseDescription) at '\(context!)'"
		}()

		XCTContext.runActivity(named: activityDescription) { _ in
			activityBlock()
		}
	}

	private func tapElement(withName controlName: String, context: String? = nil) {
		if let control = _findControl(name: controlName, context: context, elementTypes: _tapableElementTypes) {
			control.tap()
		}
		else {
			XCTAssert(false, "Could not find control with name '\(controlName)'")
		}
	}

	private func tapOutside(_ control: XCUIElement) {
		let frame = control.frame
		let x = frame.origin.x / 2
		let y = frame.origin.y / 2
		self.tapAtCoordinate(x: Double(x), y: Double(y))
	}

	private func tapAtCoordinate(x xCoordinate: Double, y yCoordinate: Double) {
		let normalized = XCUIApplication().coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
		let coordinate = normalized.withOffset(CGVector(dx: xCoordinate, dy: yCoordinate))
		coordinate.tap()
	}

	private func tapNavigationBarDoneButton() {
		let findDoneButton: () -> XCUIElement? = { () in
			let navBar = _findElement(withName: nil, inQuery: XCUIApplication().navigationBars)
			let query = navBar.descendants(matching: .button).matching(identifier: "Done")
			return query.count > 0 ? query.element(boundBy: 0) : nil
		}

		guard let element = findDoneButton() else {
			XCTFail("Could not find navigation bar button Done")
			return
		}
		element.tap()
	}

	private func alertMessageFullText(from alertsQuery: XCUIElementQuery) -> String? {
		// GeneXus' msg function may split the text if it has several lines
		alertsQuery
			.descendants(matching: .staticText)
			.allElementsBoundByIndex
			.map { (e) -> String in e.label }
			.joined(separator: " ")
	}

	// MARK: Date & Times

	private func monthName(for month: Int) -> String {
		return DateFormatter().standaloneMonthSymbols[month-1]
	}

	private func matchesMonth(_ month: Int, year: Int, with monthLabel: String) -> Bool {
		guard month >= 1 && month <= 12 else { return false }

		let monthName = self.monthName(for: month)
		return monthLabel.compare("\(monthName) \(year)", options: .caseInsensitive) == .orderedSame
	}

	private func useNewDateTimePicker() -> Bool {
		if #available(iOS 14, *) {
			// MARK: TODO: see issue 85631
			// return true
			return false
		}
		else {
			return false
		}
	}

	private func isInline(datePicker: XCUIElement) -> Bool {
		if datePicker.elementType != .datePicker {
			return false
		}
		// inline date pickers have several buttons inside them, while compact date pickers do not have any.
		return datePicker.descendants(matching: .button).count > 0
	}

	private func findDatePicker(name: String, context: String?) -> XCUIElement? {
		guard let datePicker = _findControl(name: name, context: context, elementTypes: [.datePicker]) else { return nil }

		if (isInline(datePicker: datePicker)) {
			return datePicker
		}
		else {
			// if the date picker is not inline, a tap is needed to display the "real" picker
			datePicker.tap()

			// the "real" picker is always the first one
			return XCUIApplication().descendants(matching: .datePicker).element(boundBy: 0)
		}
	}

	private func pickDate(_ datePicker: XCUIElement, year: Int, month: Int, day: Int) {
		if useNewDateTimePicker() {
			let monthButton = datePicker.descendants(matching: .button).matching(identifier: "Month").element(boundBy: 0)

			let monthName = self.monthName(for: month)

			if !matchesMonth(month, year: year, with: monthButton.value as! String) {
				// this should work but it does not...
				/*
				monthButton.tap()

				let yearWheel = datePicker.descendants(matching: .pickerWheel).element(boundBy: 1)
				yearWheel.adjust(toPickerWheelValue: String(year))

				let monthWheel = datePicker.descendants(matching: .pickerWheel).element(boundBy: 0)
				monthWheel.adjust(toPickerWheelValue: monthName)

				monthButton.tap()
				*/

				// workarround for the not-working code above
				let monthButtonLabel = monthButton.value as! String
				let components = monthButtonLabel.split(separator: " ")
				let yearSelected = Int(String(components[1]))!
				let monthSelected: Int = DateFormatter().standaloneMonthSymbols.firstIndex(of: String(components[0]))! + 1
				let inThePast = year < yearSelected || (year == yearSelected && month < monthSelected)
				let advanceMonthButton = datePicker
					.descendants(matching: .button)
					.matching(identifier: inThePast ? "Previous Month" : "Next Month")
					.element(boundBy: 0)

				repeat {
					advanceMonthButton.tap()
				} while !matchesMonth(month, year: year, with: monthButton.value as! String)
			}

			// find the right button to tap
			let dayButton = datePicker
				.descendants(matching: .button)
				.matching(NSPredicate(format: "label contains[cd] %@", "\(day)"))
				.matching(NSPredicate(format: "label contains[cd] %@", monthName))
				.element(boundBy: 0)
			dayButton.tap()
		}
		else { // !useNewDateTimePicker()
			// ¿ d-m-y or m-d-y ?
			let firstWheel = datePicker.descendants(matching: .pickerWheel).element(boundBy: 0)
			let firstValue = firstWheel.value as! String
			let dayIndex = Int(firstValue) != nil ? 0 : 1
			let monthIndex = Int(firstValue) != nil ? 1 : 0

			let yearWheel = datePicker.descendants(matching: .pickerWheel).element(boundBy: 2)
			yearWheel.adjust(toPickerWheelValue: String(year))

			let monthWheel = datePicker.descendants(matching: .pickerWheel).element(boundBy: monthIndex)
			let monthName = self.monthName(for: month)
			monthWheel.adjust(toPickerWheelValue: monthName)

			let dayWheel = datePicker.descendants(matching: .pickerWheel).element(boundBy: dayIndex)
			dayWheel.adjust(toPickerWheelValue: String(day))
		}
	}

	private func pickTime(_ datePicker: XCUIElement, hour: Int, minute: Int) {
		if useNewDateTimePicker() {
			let timePicker = datePicker
				.descendants(matching: .any)
				.matching(NSPredicate(format: "label contains[cd] %@", "Time Picker"))
				.element(boundBy: 0)

			var hourToSet = hour

			let timePickerButtons = timePicker.descendants(matching: .button)
			if timePickerButtons.count > 0 {
				let amPmButtonIdentifier = hour < 12 ? "AM" : "PM"
				let amPmButton = timePicker
					.descendants(matching: .button)
					.matching(identifier: amPmButtonIdentifier)
					.element(boundBy: 0)
				amPmButton.tap()

				if hour > 12 {
					hourToSet = hour - 12
				}
			}

			let timeField = timePicker
				.descendants(matching: .textField)
				.matching(identifier: "Time")
				.element(boundBy: 0)

			timeField.tap()
			timeField.typeText("\(hourToSet * 100 + minute)")
		}
		else {	// !useNewDateTimePicker()
			// ¿H:m or h:m:a?
			let pickerWheels = datePicker.descendants(matching: .pickerWheel)
			let hasAMPM = pickerWheels.count == 3

			let hourWheel = pickerWheels.element(boundBy: 0)
			let hourValue = hasAMPM ? String(hour % 12) : String(hour)
			hourWheel.adjust(toPickerWheelValue: hourValue)

			let minuteWheel = pickerWheels.element(boundBy: 1)
			let minuteStr = (minute < 10 ? "0" : "") + String(minute)
			minuteWheel.adjust(toPickerWheelValue: minuteStr)

			if hasAMPM {
				let amPmWheel = pickerWheels.element(boundBy: 2)
				amPmWheel.adjust(toPickerWheelValue: hour >= 12 ? "PM" : "AM")
			}
		}
	}

	// MARK: Comparing texts

	private func controlValueString(control: XCUIElement?) -> String? {
		guard let control = control else {
			return nil
		}

		var value: Any? = nil
		switch control.elementType {
		case .staticText:
			value = control.label
		case .segmentedControl:
			let buttonsQuery = control.descendants(matching: .button)
			for i in 0..<buttonsQuery.count {
				let button = buttonsQuery.element(boundBy: i)
				if button.isSelected {
					value = button.label
					break
				}
			}
		default:
			value = control.value
		}

		return value as? String
	}

	private func isEqualTextValue(_ received: String, to expected: String) -> Bool {
		if received == expected {
			return true
		}
		else {
			let expectedNoNewlines = expected.replacingOccurrences(of: "\n", with: " ")
			return received == expectedNoNewlines
		}
	}
}

// MARK: - Internal variables and functions

fileprivate let _anyElementTypes: Array<XCUIElement.ElementType> = [.any]

fileprivate let _allElementTypes: Array<XCUIElement.ElementType> = [.textField,
																	.textView,
																	.secureTextField,
																	.staticText,
																	.button,
																	.table,
																	.image,
																	.checkBox,
																	.switch,
																	.segmentedControl,
																	.other]

fileprivate let _tapableElementTypes: Array<XCUIElement.ElementType> = [.button,
																		.textField,
																		.textView,
																		.secureTextField,
																		.staticText,
																		.table,
																		.image,
																		.checkBox,
																		.switch,
																		.segmentedControl,
																		.other]

fileprivate let _textInputElementTypes: Array<XCUIElement.ElementType> = [.textField,
																		  .textView,
																		  .secureTextField,
																		  .other]

fileprivate func _waitMilliseconds(_ milliseconds: Int) {
	_waitSeconds(Double(milliseconds) / 1000.0)
}
fileprivate func _waitSeconds(_ seconds: TimeInterval) {
	Thread.sleep(forTimeInterval: seconds)
}

fileprivate func _applyControlNameCasing(_ name: String) -> String {
	guard name.count > 0 else { return name }
	let head = name.prefix(1).uppercased()
	let tail = name.dropFirst().lowercased()
	return head + tail
}

fileprivate func _findContextElement(_ context: String?, root: XCUIElement) -> XCUIElement? {
	guard let context = context else {
		return root;
	}

	let components = context.components(separatedBy: CharacterSet(charactersIn: "."))
	var searchRoot = root
	for component in components {
		if let itemIndex = _findItemIndex(in: component) {
			if itemIndex > 0 && itemIndex <= searchRoot.cells.count {
				searchRoot = searchRoot.cells.element(boundBy: itemIndex-1)
			}
			else {
				break;
			}
		}
		else {
			// control name expression
			let query = searchRoot.descendants(matching: .any).matching(identifier: _applyControlNameCasing(component))
			if query.count > 0 {
				searchRoot = query.element(boundBy: 0)
			}
			else {
				break;
			}
		}
	}
	return searchRoot;
}

fileprivate func _findItemIndex(in text: String) -> Int? {
	guard let regExp = try? NSRegularExpression(pattern: "^item\\(([0-9]+)\\)$",
												options: .caseInsensitive),
		let result = regExp.firstMatch(in: text,
										 options: .withTransparentBounds,
										 range: NSRange(location: 0, length: (text as NSString).length)),
		result.numberOfRanges > 1
	else {
		return nil
	}

	let range = result.range(at: 1)
	let match = (text as NSString).substring(with: range)
	return Int(match)
}

fileprivate func _findControl(name: String, context: String?, elementTypes: Array<XCUIElement.ElementType> = _anyElementTypes) -> XCUIElement? {
	if let context = context, context == "applicationbar" {
		return _findApplicationBarControl(name)
	}

	guard var searchRoot = _findContextElement(context, root: XCUIApplication()) else {
		return nil
	}

	let modalAlerts = searchRoot.descendants(matching: .alert)
	if (modalAlerts.count > 0) {
		searchRoot = modalAlerts.firstMatch;
	}

	return _findControl(name: name, searchRoot: searchRoot, elementTypes: elementTypes)
}

fileprivate let DEFAULT_CONTROL_EXISTANCE_TIMEOUT: UInt64 = 30 * 1_000_000_000 // 30 seconds in nanoseconds
fileprivate let DEFAULT_CONTROL_FIND_RETRY_TIMERVAL: TimeInterval = 0.5
fileprivate func _findControl(name: String, searchRoot: XCUIElement, elementTypes: Array<XCUIElement.ElementType> = _anyElementTypes) -> XCUIElement? {

	let findElementWithIdentifier = { (name: String) -> XCUIElement? in
		for elementType in elementTypes {
			let descendants = searchRoot.descendants(matching: elementType).matching(identifier: name)
			if descendants.count > 0 {
				return descendants.element(boundBy: 0)
			}
		}
		return nil
	}

	let findElementWithIdentifierIgnoringCase = { (name: String) -> XCUIElement? in
		if let result = findElementWithIdentifier(_applyControlNameCasing(name)) {
			return result
		}
		else {
			return findElementWithIdentifier(name)
		}
	}

	var control: XCUIElement?
	
	var timeWaited: UInt64 = 0
	while (control == nil && timeWaited < DEFAULT_CONTROL_EXISTANCE_TIMEOUT) {
		let startTime = DispatchTime.now()
		control = findElementWithIdentifierIgnoringCase(name)
		_waitSeconds(DEFAULT_CONTROL_FIND_RETRY_TIMERVAL)
		let elapsedTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
		timeWaited += elapsedTime
	}
	return control
}

fileprivate func _findApplicationBarControl(_ controlName: String) -> XCUIElement? {
	let findElementInQuery = { (name: String, query: XCUIElementQuery) -> XCUIElement? in
		var control: XCUIElement? = nil
		for i in 0..<query.count {
			control = _findControl(name: name, searchRoot: query.element(boundBy: i))
			if control != nil {
				break
			}
		}
		return control
	}

	var control: XCUIElement? = nil

	control = findElementInQuery(controlName, XCUIApplication().navigationBars)

	if control == nil {
		control = findElementInQuery(controlName, XCUIApplication().toolbars)
	}

	if control == nil {
		// Low priority buttons may not be present directly on screen, they may appear in an action sheet after tapping the "share" button
		var shareButtons = XCUIApplication().toolbars.descendants(matching: .button).matching(identifier: "Share")
		if shareButtons.count == 0 {
			shareButtons = XCUIApplication().navigationBars.descendants(matching: .button).matching(identifier: "Share")
		}
		if shareButtons.count > 0 {
			let shareButton = shareButtons.element(boundBy: 0)
			shareButton.tap()
			let sheets = XCUIApplication().descendants(matching: .sheet)
			if sheets.count == 1 {
				let actionSheet = sheets.element(boundBy: 0)
				let buttons = actionSheet.descendants(matching: .button).matching(identifier: controlName)
				if buttons.count == 1 {
					control = buttons.element(boundBy: 0)
				}
			}
		}
	}
	return control
}

fileprivate func _findElement(withName name: String?, inQuery query: XCUIElementQuery) -> XCUIElementQuery {
	if let name = name {
		return query.matching(identifier: name)
	}
	return query
}

fileprivate extension XCUIElement {

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

fileprivate extension CGImage {
	var data: Data? {
		guard let mutableData = CFDataCreateMutable(nil, 0),
			  let destination = CGImageDestinationCreateWithData(mutableData, "public.png" as CFString, 1, nil) else { return nil }
		CGImageDestinationAddImage(destination, self, nil)
		guard CGImageDestinationFinalize(destination) else { return nil }
		return mutableData as Data
	}
}

final public class genexus_client_SdtClientInformation : GXStandardClasses.GXUserType {
	public lazy var gxTv_SdtClientInformation_Id: String = GXClientInformation.deviceUUID(for: self) ?? ""

	public lazy var gxTv_SdtClientInformation_Osname: String = GXClientInformation.osName()

	public lazy var gxTv_SdtClientInformation_Osversion: String = GXClientInformation.osVersion()

	public lazy var gxTv_SdtClientInformation_Language: String = GXClientInformation.deviceLanguage()

	public lazy var gxTv_SdtClientInformation_Devicetype: Int = Int(GXClientInformation.deviceType())

	public lazy var gxTv_SdtClientInformation_Platformname: String = GXClientInformation.platformName(for: self)

	public lazy var gxTv_SdtClientInformation_Appversioncode: String = GXClientInformation.appVersionCode(for: self)

	public lazy var gxTv_SdtClientInformation_Appversionname: String = GXClientInformation.appVersionName(for: self)

	public lazy var gxTv_SdtClientInformation_Applicationid: String = GXClientInformation.appIdentifier(for: self)
}

fileprivate class VisualTestingProvider {
	
	enum VisualTestingError: Error {
		case invalidURL
		case failedToUploadImage
		case couldNotSerializeParameters
	}
	
	// MARK: Properties
	
	let projectCode: String
	let testName: String
	let reference: String
	
	var baseURLString: String {
		let baseURL = SdtUITestSD.visualTestingServer
		let separator = baseURL.hasSuffix("/") ? "" : "/"
		return "\(baseURL)\(separator)"
	}

	var getResourceURL: URL? { URL(string: "\(baseURLString)GetResource") }

	var setResourceURL: URL? { URL(string: "\(baseURLString)SetResource") }
	
	var imageUploadURL: URL? { URL(string: "\(baseURLString)SetResource/gxobject")}

	// MARK: Init
	
	init(projectCode: String, testName: String, reference: String) {
		self.projectCode = projectCode
		self.testName = testName
		self.reference = reference
	}
	
	// MARK: Public API
	
	func getReferenceImage() throws -> UIImage? {
		guard let requestURL = getResourceURL else {
			throw VisualTestingError.invalidURL
		}
		let params: Dictionary<String, Any> = ["projectCode": projectCode, "testCode": testName, "resourceReference": reference, "platform": 1]
		guard let paramsData = try? JSONSerialization.data(withJSONObject: params, options: []) else {
			return nil
		}
		guard let postResult = awaitPost(toURL: requestURL, data: paramsData, mimeType: "application/json", resultKey: "image") else {
			return nil
		}
		return getImage(from: postResult)
	}
	
	func saveReferenceImage(image: UIImage) throws {
		guard let requestURL = setResourceURL else {
			throw VisualTestingError.invalidURL
		}
		
		guard let gxuploadCode = try? uploadImage(image: image) else {
			throw VisualTestingError.failedToUploadImage
		}
		
		let params: Dictionary<String, Any> = ["projectCode": projectCode, "testCode": testName, "resourceReference": reference, "platform": 1, "image": gxuploadCode]
		guard let paramsData = try? JSONSerialization.data(withJSONObject: params, options: []) else {
			throw VisualTestingError.couldNotSerializeParameters
		}
		
		awaitPost(toURL: requestURL, data: paramsData, mimeType: "application/json")
	}
	
	func saveImageWithDifference(image: UIImage) throws {
		// Using the same service used to save a new reference image
		try self.saveReferenceImage(image: image)
	}
	
	// MARK: Private
	
	private func getImage(from urlString: String) -> UIImage? {
		guard
			let url = URL(string: urlString),
			let resultData = awaitGet(fromURL: url)
		else {
			return nil
		}
		return UIImage(data: resultData)
	}
	
	private func uploadImage(image: UIImage) throws -> String? {
		guard let requestURL = imageUploadURL else {
			throw VisualTestingError.invalidURL
		}
		guard let pngData = image.pngData() else {
			return nil
		}
		return awaitPost(toURL: requestURL, data: pngData, mimeType: "image/png", resultKey: "object_id")
	}
	
	// MARK: Network
	
	private func awaitGet(fromURL requestURL: URL) -> Data? {
		var result: Data? = nil
		
		let semaphore = DispatchSemaphore(value: 0)
		let task = URLSession.shared.dataTask(with: requestURL) { data, response, error in
			defer { semaphore.signal() }
			guard let data = data,
				  error == nil,
				  let response = response as? HTTPURLResponse,
				  response.statusCode >= 200,
				  response.statusCode < 300
			else {
				return
			}
			result = data
		}
		task.resume()
		semaphore.wait()
		
		return result
	}
	
	private func postRequest(forURL requestURL: URL, data: Data, mimeType: String) -> URLRequest {
		var request = URLRequest(url: requestURL)
		request.httpMethod = "POST"
		request.httpBody = data
		request.addValue(mimeType, forHTTPHeaderField: "Content-Type")
		return request
	}
	
	private func awaitPost(toURL requestURL: URL, data: Data, mimeType: String) {
		let request = postRequest(forURL: requestURL, data: data, mimeType: mimeType)
		let semaphore = DispatchSemaphore(value: 0)
		let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
			semaphore.signal()
		})
		task.resume()
		semaphore.wait()
	}
	
	private func awaitPost(toURL requestURL: URL, data: Data, mimeType: String, resultKey: String) -> String? {
		var result: String? = nil
		
		let request = postRequest(forURL: requestURL, data: data, mimeType: mimeType)
		let semaphore = DispatchSemaphore(value: 0)
		let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
			defer { semaphore.signal() }
			guard let data = data, error == nil else {
				return
			}
			do {
				let json = try JSONSerialization.jsonObject(with: data) as? Dictionary<String, AnyObject>
				result = json?[resultKey] as? String
			} catch { }
		})
		task.resume()
		semaphore.wait()
		
		return result
	}
}
private struct GXUITestingHelpers {
	enum ScreenshotClippingStyle {
		case none
		case statusBarOnly
		case safeArea
	}
	static func screenshotImage(from control: XCUIScreenshotProviding, clipToSafeArea: ScreenshotClippingStyle = .none) -> UIImage {
		var screenshot = control.screenshot().image
		if clipToSafeArea != .none {
			let safeAreaInsets = AppleDeviceModel.current.safeAreaInsets(for: .portrait).scaled(by: screenshot.scale)
			let scaledSize = screenshot.size.scaled(by: screenshot.scale)
			let croppingRect: CGRect!
			if clipToSafeArea == .safeArea {
				croppingRect = CGRect(x: safeAreaInsets.left, y: safeAreaInsets.top,
									  width: scaledSize.width - (safeAreaInsets.left + safeAreaInsets.right),
									  height: scaledSize.height - (safeAreaInsets.top + safeAreaInsets.bottom))
			} else if clipToSafeArea == .statusBarOnly {
				croppingRect = CGRect.init(x: 0, y: safeAreaInsets.top, width: scaledSize.width, height: scaledSize.height - safeAreaInsets.top)
			} else {
				fatalError("Invalid screenshot cropping style")
			}
			screenshot = UIImage(cgImage: screenshot.cgImage!.cropping(to: croppingRect)!)
		}
		return screenshot
	}
}
private enum AppleDeviceModel : String {
#if os(iOS)
	case iPodTouch6thGeneration = "iPod touch (6th generation)"
	case iPodTouch7thGeneration = "iPod touch (7th generation)"
	
	case iPhone5S = "iPhone 5s"
	case iPhone6	 = "iPhone 6"
	case iPhone6Plus = "iPhone 6 Plus"
	case iPhone6S 		= "iPhone 6s"
	case iPhone6SPlus 	= "iPhone 6s Plus"
	case iPhoneSE1stGeneration = "iPhone SE"
	case iPhone7 		= "iPhone 7"
	case iPhone7Plus 	= "iPhone 7 Plus"
	case iPhone8 		= "iPhone 8"
	case iPhone8Plus 	= "iPhone 8 Plus"
	case iPhoneX		= "iPhone X"
	case iPhoneXS		= "iPhone XS"
	case iPhoneXSMax	= "iPhone XS Max"
	case iPhoneXR		= "iPhone XR"
	case iPhone11		= "iPhone 11"
	case iPhone11Pro	= "iPhone 11 Pro"
	case iPhone11ProMax	= "iPhone 11 Pro Max"
	case iPhoneSE2ndGeneration = "iPhone SE (2nd generation)"
	case iPhone12Mini	= "iPhone 12 mini"
	case iPhone12		= "iPhone 12"
	case iPhone12Pro	= "iPhone 12 Pro"
	case iPhone12ProMax	= "iPhone 12 Pro Max"
	case iPhone13Mini	= "iPhone 13 mini"
	case iPhone13		= "iPhone 13"
	case iPhone13Pro	= "iPhone 13 Pro"
	case iPhone13ProMax	= "iPhone 13 Pro Max"
	case iPhoneSE3rdGeneration = "iPhone SE (3rd generation)"
	case iPhone14		= "iPhone 14"
	case iPhone14Plus	= "iPhone 14 Plus"
	case iPhone14Pro	= "iPhone 14 Pro"
	case iPhone14ProMax	= "iPhone 14 Pro Max"
	case iPad5thGeneration = "iPad (5th generation)"
	case iPad6thGeneration = "iPad (6th generation)"
	case iPad7thGeneration = "iPad (7th generation)"
	case iPad8thGeneration = "iPad (8th generation)"
	case iPad9thGeneration = "iPad (9th generation)"
	case iPad10thGeneration = "iPad (10th generation)"
	case iPadAir	= "iPad Air"
	case iPadAir2 	= "iPad Air 2"
	case iPadAir3rdGeneration = "iPad Air (3rd generation)"
	case iPadAir4thGeneration = "iPad Air (4th generation)"
	case iPadAir5thGeneration = "iPad Air (5th generation)"
	case iPadMini2 = "iPad mini 2"
	case iPadMini3 = "iPad mini 3"
	case iPadMini4 = "iPad mini 4"
	case iPadMini5thGeneration = "iPad mini (5th generation)"
	case iPadMini6thGeneration = "iPad mini (6th generation)"
	case iPadPro9_7	 = "iPad Pro (9.7-inch)"
	case iPadPro10_5 = "iPad Pro (10.5-inch)"
	case iPadPro111stGeneration = "iPad Pro (11-inch) (1st generation)"
	case iPadPro112ndGeneration = "iPad Pro (11-inch) (2nd generation)"
	case iPadPro113rdGeneration = "iPad Pro (11-inch) (3rd generation)"
	case iPadPro114thGeneration = "iPad Pro (11-inch) (4th generation)"
	case iPadPro12_91stGeneration = "iPad Pro (12.9-inch) (1st generation)"
	case iPadPro12_92ndGeneration = "iPad Pro (12.9-inch) (2nd generation)"
	case iPadPro12_93rdGeneration = "iPad Pro (12.9-inch) (3rd generation)"
	case iPadPro12_94thGeneration = "iPad Pro (12.9-inch) (4th generation)"
	case iPadPro12_95thGeneration = "iPad Pro (12.9-inch) (5th generation)"
	case iPadPro12_96thGeneration = "iPad Pro (12.9-inch) (6th generation)"
#elseif os(tvOS)
	case AppleTV 	= "Apple TV"
	case AppleTV4K 	= "Apple TV 4K"
#elseif os(watchOS)
	// ...
#endif
	static let current: AppleDeviceModel = {
		var systemInfo = utsname()
		uname(&systemInfo)
		let machineMirror = Mirror(reflecting: systemInfo.machine)
		var identifier = machineMirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8, value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}
		func mapToModelName(identifier: String) -> String {
#if os(iOS)
			switch identifier {
			case "iPod7,1":                                       return "iPod touch (6th generation)"
			case "iPod9,1":                                       return "iPod touch (7th generation)"
			case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
			case "iPhone7,2":                                     return "iPhone 6"
			case "iPhone7,1":                                     return "iPhone 6 Plus"
			case "iPhone8,1":                                     return "iPhone 6s"
			case "iPhone8,2":                                     return "iPhone 6s Plus"
			case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
			case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
			case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
			case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
			case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
			case "iPhone11,2":                                    return "iPhone XS"
			case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
			case "iPhone11,8":                                    return "iPhone XR"
			case "iPhone12,1":                                    return "iPhone 11"
			case "iPhone12,3":                                    return "iPhone 11 Pro"
			case "iPhone12,5":                                    return "iPhone 11 Pro Max"
			case "iPhone13,1":                                    return "iPhone 12 mini"
			case "iPhone13,2":                                    return "iPhone 12"
			case "iPhone13,3":                                    return "iPhone 12 Pro"
			case "iPhone13,4":                                    return "iPhone 12 Pro Max"
			case "iPhone14,4":                                    return "iPhone 13 mini"
			case "iPhone14,5":                                    return "iPhone 13"
			case "iPhone14,2":                                    return "iPhone 13 Pro"
			case "iPhone14,3":                                    return "iPhone 13 Pro Max"
			case "iPhone14,7":                                    return "iPhone 14"
			case "iPhone14,8":                                    return "iPhone 14 Plus"
			case "iPhone15,2":                                    return "iPhone 14 Pro"
			case "iPhone15,3":                                    return "iPhone 14 Pro Max"
			case "iPhone8,4":                                     return "iPhone SE"
			case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
			case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
			case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
			case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
			case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
			case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
			case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
			case "iPad13,18", "iPad13,19":                        return "iPad (10th generation)"
			case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
			case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
			case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
			case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
			case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
			case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
			case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
			case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
			case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
			case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
			case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
			case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
			case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
			case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
			case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
			case "iPad14,3", "iPad14,4":                          return "iPad Pro (11-inch) (4th generation)"
			case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
			case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
			case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
			case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
			case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
			case "iPad14,5", "iPad14,6":                          return "iPad Pro (12.9-inch) (6th generation)"
			case "i386", "x86_64", "arm64":                       return mapToModelName(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!)
			default:                                              return identifier
			}
#endif // os(iOS)
		}
		identifier = mapToModelName(identifier: identifier)
		guard let currentDeviceModel = AppleDeviceModel.init(rawValue: identifier) else {
			fatalError("Unable to determine current device model from identifier: \(identifier)")
		}
		return currentDeviceModel
	}()
	private enum SafeAreaInsetsCategory {
		case originaliPhoneDesign
		case iPhoneXLike
		case iPhone11Like
		case iPhone12Like
		case iPhone12MiniLike
		case iPhone14ProLike
		case originaliPadDesign
		case iPadWithoutTouchID
		func safeAreaInsets(for orientation: UIDeviceOrientation) -> UIEdgeInsets {
			switch self {
			case .originaliPhoneDesign, .originaliPadDesign:
				return .init(top: 20, left: 0, bottom: 0, right: 0)
			case .iPhoneXLike:
				return orientation.isPortrait ? .init(top: 44, left: 0, bottom: 34, right: 0) : .init(top: 0, left: 44, bottom: 21, right: 44)
			case .iPhone11Like:
				return orientation.isPortrait ? .init(top: 48, left: 0, bottom: 34, right: 0) : .init(top: 0, left: 48, bottom: 21, right: 48)
			case .iPhone12Like:
				return orientation.isPortrait ? .init(top: 47, left: 0, bottom: 34, right: 0) : .init(top: 0, left: 47, bottom: 21, right: 47)
			case .iPhone12MiniLike:
				return orientation.isPortrait ? .init(top: 50, left: 0, bottom: 34, right: 0) : .init(top: 0, left: 50, bottom: 21, right: 50)
			case .iPhone14ProLike:
				return orientation.isPortrait ? .init(top: 59, left: 0, bottom: 34, right: 0) : .init(top: 0, left: 59, bottom: 21, right: 59)
			case .iPadWithoutTouchID:
				return .init(top: 24, left: 0, bottom: 0, right: 0)
			}
		}
	}
	private var safeAreaInsetsCategory: SafeAreaInsetsCategory {
		switch self {
		case .iPodTouch6thGeneration, .iPodTouch7thGeneration, .iPhone5S, .iPhone6, .iPhone6Plus, .iPhone6S, .iPhone6SPlus, .iPhoneSE1stGeneration, .iPhone7, .iPhone7Plus, .iPhone8, .iPhone8Plus, .iPhoneSE2ndGeneration, .iPhoneSE3rdGeneration:
			return .originaliPhoneDesign
		case .iPhoneX, .iPhoneXS, .iPhoneXSMax, .iPhone11Pro, .iPhone11ProMax:
			return .iPhoneXLike
		case .iPhoneXR, .iPhone11:
			return .iPhone11Like
		case .iPhone12, .iPhone12Pro, .iPhone12ProMax, .iPhone13, .iPhone13Pro, .iPhone13ProMax, .iPhone14, .iPhone14Plus:
			return .iPhone12Like
		case .iPhone12Mini, .iPhone13Mini:
			return .iPhone12MiniLike
		case .iPhone14Pro, .iPhone14ProMax:
			return .iPhone14ProLike
		case .iPad5thGeneration, .iPad6thGeneration, .iPad7thGeneration, .iPad8thGeneration, .iPad9thGeneration, .iPadAir, .iPadAir2, .iPadAir3rdGeneration, .iPadAir4thGeneration, .iPadAir5thGeneration, .iPadMini2, .iPadMini3, .iPadMini4, .iPadMini5thGeneration, .iPadPro9_7, .iPadPro10_5, .iPadPro12_91stGeneration, .iPadPro12_92ndGeneration:
			return .originaliPadDesign
		case .iPad10thGeneration, .iPadMini6thGeneration, .iPadPro111stGeneration, .iPadPro112ndGeneration, .iPadPro113rdGeneration, .iPadPro114thGeneration, .iPadPro12_93rdGeneration, .iPadPro12_94thGeneration, .iPadPro12_95thGeneration, .iPadPro12_96thGeneration:
			return .iPadWithoutTouchID
		}
	}
	func safeAreaInsets(for orientation: UIDeviceOrientation) -> UIEdgeInsets {
		self.safeAreaInsetsCategory.safeAreaInsets(for: orientation)
	}
}

private extension UIEdgeInsets {
	func scaled(by scale: CGFloat) -> UIEdgeInsets {
		UIEdgeInsets.init(top: self.top * scale, left: self.left * scale, bottom: self.bottom * scale, right: self.right * scale)
	}
}
private extension CGSize {
	func scaled(by scale: CGFloat) -> CGSize {
		CGSize.init(width: self.width * scale, height: self.height * scale)
	}
}
internal enum GXUITestError : Error {
	case runtimeError(String)
}
