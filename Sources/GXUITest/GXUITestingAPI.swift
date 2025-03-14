//
//  GXUITestingAPI.swift
//

import XCTest

@_exported import Foundation
@_exported import GXStandardClasses
import GXObjectsModel

// MARK: - GeneXus UI Test object

protocol VisualTestingServerProvider {
	static var visualTestingServer: String { get }
}

public class SdtUITestSD : VisualTestingServerProvider {
	
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
					let visualTestingProvider = VisualTestingProvider(projectCode: bundleId, testName: testName, reference: reference, serverProvider: self)
					
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
			value = control.value
			if value == nil || (value as? String)?.isEmpty == true {
				value = control.label
			}
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
								    									.scrollView,
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
																		.scrollView,
																		.other]

fileprivate let _textInputElementTypes: Array<XCUIElement.ElementType> = [.textField,
																		  .textView,
																		  .secureTextField,
																		  .other]

internal func _waitMilliseconds(_ milliseconds: Int) { _waitSeconds(Double(milliseconds) / 1000.0) }
fileprivate func _waitSeconds(_ seconds: TimeInterval) { Thread.sleep(forTimeInterval: seconds) }

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
