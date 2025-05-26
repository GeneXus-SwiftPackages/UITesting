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
		runActivity(forAction: "Back", target: nil, inContext: nil) {
			// Note: back button is (generally...) the first button in the navigation bar
			let backButton = XCUIApplication().navigationBars.buttons.firstMatch
			guard backButton.exists else {
				XCTFail("Could not find back button")
				return
			}
			if backButton.isHittable {
				backButton.tap()
			}
			else {
				// Hack: sometimes a button is identifing as hittable, so send a tap directly to the middle of it
				backButton.coordinate(withNormalizedOffset: CGVector(dx:0.5, dy:0.5)).tap()
			}
		}
	}
	
	public func tap(_ target: String, _ context: String? = nil) {
		runActivity(forAction: "Tap", target: target, inContext: context) {
			let elementTypes = _tapableElementTypes
			guard let control = _findElement(ElementSearchIdentifier.target(target), context: context, elementTypes: elementTypes, disambiguateUsing: _elementTypeDisambiguator(for: elementTypes)) else {
				XCTFail("Could not find target '\(target)'")
				return
			}
			control.tap()
		}
	}
	
	public func longtap(_ target: String, _ context: String? = nil) {
		runActivity(forAction: "LongTap", target: target, inContext: context) {
			let elementTypes = _tapableElementTypes
			guard let control = _findElement(ElementSearchIdentifier.target(target), context: context, elementTypes: elementTypes, disambiguateUsing: _elementTypeDisambiguator(for: elementTypes)) else {
				XCTFail("Could not find target '\(target)'")
				return
			}
			control.press(forDuration: 1.0)
		}
	}
	
	public func doubletap(_ target: String, _ context: String? = nil) {
		runActivity(forAction: "DoubleTap", target: target, inContext: context) {
			let elementTypes = _tapableElementTypes
			guard let control = _findElement(ElementSearchIdentifier.target(target), context: context, elementTypes: elementTypes, disambiguateUsing: _elementTypeDisambiguator(for: elementTypes)) else {
				XCTFail("Could not find target '\(target)'")
				return
			}
			control.doubleTap()
		}
	}
	
	public func fill(_ controlName: String, _ value: String, _ context: String? = nil) {
		runActivity(forAction: "Fill", target: controlName, inContext: context) {
			guard let control = _findElement(.controlName(controlName), context: context, elementTypes: _textInputElementTypes) else {
				XCTFail("Could not find control with name '\(controlName)'")
				return
			}
			control.repaceText(value)
		}
	}
	
	public func pickdate(_ controlName: String, _ year: Int, _ month: Int, _ day: Int, _ context: String? = nil) {
		runActivity(forAction: "PickDate", target: controlName, inContext: context) {
			if useNewDateTimePicker() {
				guard let datePicker = findDatePicker(name: controlName, context: context) else {
					XCTFail("Could not find date picker for control '\(controlName)'")
					return
				}
				pickDate(datePicker, year: year, month: month, day: day)
				self.tapOutside(datePicker)
			}
			else {	// !useNewDateTimePicker()
				guard let dateField = _findElement(.controlName(controlName), context: context) else {
					XCTFail("Could not find control with name '\(controlName)'")
					return
				}
				dateField.tap()
				let datePickers = XCUIApplication().descendants(matching: .datePicker)
				guard datePickers.count > 0 else {
					XCTFail("Could not find date picker for control '\(controlName)'")
					return
				}
				pickDate(datePickers.element(boundBy: datePickers.count-1), year: year, month: month, day: day)
			}
		}
	}
	
	public func pickdatetime(_ controlName: String, _ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minutes: Int, _ context: String? = nil) {
		runActivity(forAction: "PickDateTime", target: controlName, inContext: context) {
			if useNewDateTimePicker() {
				guard let datePicker = findDatePicker(name: controlName, context: context) else {
					XCTFail("Could not find date picker for control '\(controlName)'")
					return
				}
				pickDate(datePicker, year: year, month: month, day: day)
				pickTime(datePicker, hour: hour, minute: minutes)
				self.tapAtCoordinate(x: 0, y: 0)
			}
			else { // !useNewDateTimePicker()
				guard let dateTimeField = _findElement(.controlName(controlName), context: context) else {
					XCTFail("Could not find control with name '\(controlName)'")
					return
				}
				dateTimeField.tap()
				
				let dateItem = XCUIApplication().tables.cells.element(boundBy: 0)
				dateItem.tap()
				
				let datePickers = XCUIApplication().descendants(matching: .datePicker)
				guard datePickers.count > 0 else {
					XCTFail("Could not find date picker for control '\(controlName)'")
					return
				}
				pickDate(datePickers.element(boundBy: datePickers.count-1), year: year, month: month, day: day)
				
				let timeItem = XCUIApplication().tables.cells.element(boundBy: 1)
				timeItem.tap()
				
				let timePickers = XCUIApplication().descendants(matching: .datePicker)
				if timePickers.count > 0 {
					pickTime(timePickers.element(boundBy: timePickers.count-1), hour: hour, minute: minutes)
				}
				else {
					XCTFail("Could not find time picker for control '\(controlName)'")
				}
				
				tapNavigationBarDoneButton()
			}
		}
	}
	
	public func picktime(_ controlName: String, _ hour: Int, _ minutes: Int, _ context: String? = nil) {
		runActivity(forAction: "PickTime", target: controlName, inContext: context) {
			if useNewDateTimePicker() {
				guard let datePicker = findDatePicker(name: controlName, context: context) else {
					XCTFail("Could not find date picker for control '\(controlName)'")
					return
				}
				pickTime(datePicker, hour: hour, minute: minutes)
				self.tapAtCoordinate(x: 0, y: 0)
			}
			else {	// !useNewDateTimePicker()
				guard let timeField = _findElement(.controlName(controlName), context: context) else {
					XCTFail("Could not find control with name '\(controlName)'")
					return
				}
				timeField.tap()
				
				let timePickers = XCUIApplication().descendants(matching: .datePicker)
				if timePickers.count > 0 {
					pickTime(timePickers.element(boundBy: timePickers.count-1), hour: hour, minute: minutes)
				}
				else {
					XCTFail("Could not find time picker for control '\(controlName)'")
				}
			}
		}
	}
	
	public func selectvalue(_ controlName: String, _ value: String, _ context: String? = nil) {
		runActivity(forAction: "SelectValue", target: controlName, inContext: context) {
			guard let control = _findElement(.controlName(controlName), context: context, elementTypes: _allElementTypes) else {
				XCTFail("Could not find control with name '\(controlName)'")
				return
			}
			let valueElement: XCUIElement?
			switch control.elementType {
			case .segmentedControl:
				valueElement = _findElement(.visibleText(value), searchRoot: control, elementTypes: _tapableElementTypes, timeout: 0)
			case .table:
				let cell = control.cells.containing(ElementSearchIdentifier.visibleText(value).predicate).firstMatch
				valueElement = cell.waitForExistence(timeout: 1) ? cell : nil
			default:
				control.tap()
				valueElement = _findElement(.visibleText(value), searchRoot: XCUIApplication(), elementTypes: _tapableElementTypes, timeout: 5)
			}
			guard let valueElement else {
				XCTFail("Could not find value '\(value)' in control with name '\(controlName)'")
				return
			}
			valueElement.tap()
		}
	}
	
	public func swipe(_ direction: Int, _ controlName: String? = nil, _ context: String? = nil) {
		let swipeDirection: GXSwipeDirection = .init(rawValue: direction) ?? .left
		runActivity(forAction: "Swipe \(swipeDirection.description)", target: controlName, inContext: context) {
			let targetControlName = controlName ?? "maintable"
			guard let control = _findElement(.controlName(targetControlName), context: context) else {
				XCTFail("Could not find control with name '\(targetControlName)'")
				return
			}
			control.swipe(swipeDirection)
		}
	}
	
	public func wait(_ milliseconds: Int) {
		runActivity(forAction: "Wait", target: nil, inContext: nil) {
			_waitMilliseconds(milliseconds)
		}
	}
	
	public func verifytext(_ text: String, _ expected: Bool = true, _ context: String? = nil) {
		runActivity(forAction: "VerifyText", target: text, inContext: context) {
			let timeout: TimeInterval = expected ? DEFAULT_ELEMENT_EXISTANCE_TIMEOUT : DEFAULT_ELEMENT_NON_EXISTANCE_TIMEOUT
			let foundAndVisible: Bool = _findElement(.visibleText(text), context: context, includingContextElement: true, timeout: timeout)?.isHittable ?? false
			XCTAssert(foundAndVisible == expected, "Text '\(text)' was \(expected ? "" : "not ")expected but did \(foundAndVisible ? "" : "not ")find it")
		}
	}
	
	public func verifygridrowscount(_ controlName: String, _ count: Int, _ expected: Bool = true, _ context: String? = nil) {
		runActivity(forAction: "VerifyGridRowsCount", target: controlName, inContext: context) {
			guard let control = _findElement(.controlName(controlName), context: context, elementTypes: _allElementTypes) else {
				XCTFail("Could not find grid with name '\(controlName)'")
				return
			}
			let rows = control.children(matching: .cell).matching(NSPredicate(format: "identifier != %@", GXAccessibilityTag.loadingCell.tagString)).count
			if expected {
				XCTAssertEqual(rows, count, "Grid '\(controlName)' should have \(count) rows, found \(rows).")
			}
			else {
				XCTAssertNotEqual(rows, count, "Grid '\(controlName)' should not have \(count) rows, found \(rows).")
			}
		}
	}
	
	public func verifycheckbox(_ controlName: String, _ value: Bool, _ context: String? = nil) {
		runActivity(forAction: "VerifyCheckbox", target: controlName, inContext: context) {
			guard let control = _findElement(.controlName(controlName), context: context, elementTypes: _allElementTypes) else {
				XCTFail("Could not find control with name '\(controlName)'")
				return
			}
			let selected = control.isSelected;
			XCTAssert(selected == value, "Checkbox '\(controlName)' was expected to be \(value ? "" : "un")selected but is not.")
		}
	}
	
	public func getcheckboxvalue(_ controlName: String, _ context: String? = nil) -> Bool {
		var selected = false
		runActivity(forAction: "GetCheckboxValue", target: controlName, inContext: context) {
			guard let control = _findElement(.controlName(controlName), context: context, elementTypes: _allElementTypes) else {
				XCTFail("Could not find control with name '\(controlName)'")
				return
			}
			selected = control.isSelected
		}
		return selected
	}
	
	public func verifycontrolvalue(_ controlName: String, _ value: String, _ expected: Bool = true, _ context: String? = nil) {
		runActivity(forAction: "VerifyControlValue", target: controlName, inContext: context) {
			guard let control = _findElement(.controlName(controlName), context: context, elementTypes: _allElementTypes) else {
				XCTFail("Could not find control with name '\(controlName)'")
				return
			}
			guard let controlValueString = controlValueString(control: control) else {
				XCTFail("Could not get value for control with name '\(controlName)'")
				return
			}
			let result = isEqualTextValue(controlValueString, to: value)
			XCTAssert(result == expected, "Value '\(controlValueString)' \(expected ? "does not match expected" : "matches not expected") value '\(value)'")
		}
	}
	
	public func verifycontrolenabled( _ controlName: String, _ expected: Bool = true, _ context: String? = nil) {
		runActivity(forAction: "VerifyControlEnabled", target: controlName, inContext: context) {
			guard let control = _findElement(.controlName(controlName), context: context, elementTypes: _allElementTypes) else {
				XCTFail("Could not find control with name '\(controlName)'")
				return
			}
			let enabled = control.isEnabled
			XCTAssert(enabled == expected, "Control '\(controlName)' should \(expected ? "" : "not ")be enabled but it was\(enabled ? "" : " not").")
		}
	}
	
	public func verifymsg(_ text: String, _ expected: Bool = true) {
		runActivity(forAction: "VerifyMsg", target: text, inContext: nil) {
			let found: Bool = {
				let alertsQuery = XCUIApplication().alerts
				guard alertsQuery.firstMatch.waitForExistence(timeout: 1) else { return	false }
				return alertsQuery.allElementsBoundByIndex.contains { alert in
					let allStaticTextLabels = alert.staticTexts.allElementsBoundByIndex.map(\.label)
					return allStaticTextLabels.contains(where: { $0 == text }) ||
					(allStaticTextLabels.count > 1 && allStaticTextLabels.joined(separator: "\n") == text) /// GeneXus' msg function may split the text if it has several lines
				}
			}()
			XCTAssert(found == expected, "Alert with text '\(text)' was \(expected ? "" : "not ")expected but did \(found ? "" : "not ")find it")
		}
	}
	
	public func verifycontrolvisible(_ controlName: String, _ expected: Bool = true, _ context: String? = nil) {
		runActivity(forAction: "VerifyControlVisible", target: controlName, inContext: context) {
			let timeout: TimeInterval = expected ? DEFAULT_ELEMENT_EXISTANCE_TIMEOUT : DEFAULT_ELEMENT_NON_EXISTANCE_TIMEOUT
			guard let control = _findElement(.controlName(controlName), context: context, elementTypes: _allElementTypes, timeout: timeout) else {
				XCTAssertFalse(expected, "Could not find control with name '\(controlName)'")
				return
			}
			let visible = control.isHittable
			XCTAssert(visible == expected, "Control '\(controlName)' should \(expected ? "" : "not ")be visible but it was\(visible ? "" : " not").")
		}
	}
	
	public func iscontrolvisible( _ controlName: String, _ context: String? = nil) -> Bool {
		var visible = false
		runActivity(forAction: "IsControlVisible", target: controlName, inContext: context){
			if let control = _findElement(.controlName(controlName), context: context, elementTypes: _allElementTypes, timeout: DEFAULT_ELEMENT_NON_EXISTANCE_TIMEOUT) {
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
			guard let control = _findElement(.controlName(controlName), context: context, elementTypes: _allElementTypes) else {
				XCTFail("Could not find control with name '\(controlName)'")
				return
			}
			
			enabled = control.isEnabled
		}
		return enabled
	}
	
	public func verifyscreenshot( _ reference: String, _ controlName: String? = nil, _ context: String? = nil, testFile: String = #file ) {
		let findElement: () -> XCUIScreenshotProviding? = {
			if let controlName {
				return _findElement(.controlName(controlName, root: true), context: context)
			}
			else {
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
									XCTFail("Screenshots do not match for image reference '\(reference)'")
								}
							} catch GXUITestError.runtimeError(let errorMessage) {
								XCTFail(errorMessage)
							}
						}
					}
					else {
						// did not get image, send new reference image and make the test fail
						try? visualTestingProvider.saveReferenceImage(image: capturedImage)
						XCTFail("Server image not available for image reference '\(reference)'")
					}
				}
				catch {
					XCTFail("Unexpected error getting server image for image reference '\(reference)'")
					return
				}
			}
			else {
				if let controlName {
					XCTFail("Could not find control with name '\(controlName)'")
				}
				else {
					XCTFail("Could not find applications main screen")
				}
			}
		}
	}
	
	public func isshowingmessage() -> Bool {
		var found = false
		runActivity(forAction: "IsShowingMessage", target: nil, inContext: nil) {
			found = XCUIApplication().alerts.firstMatch.exists
		}
		return found
	}
	
	public func getcontrolvalue( _ controlName: String, _ context: String? = nil) -> String {
		var value: String?
		runActivity(forAction: "GetControlValue", target: controlName, inContext: context) {
			guard let control = _findElement(.controlName(controlName), context: context, elementTypes: _allElementTypes) else {
				XCTFail("Could not find control with name '\(controlName)'")
				return
			}
			value = controlValueString(control: control)
		}
		return value ?? ""
	}
	
	public func getmessagetext() -> String {
		var messageText :String?
		runActivity(forAction: "GetMessageText", target: nil, inContext: nil) {
			let firstAlert = XCUIApplication().alerts.firstMatch
			guard firstAlert.waitForExistence(timeout: 1) else {
				XCTFail("No alert message found")
				return
			}
			messageText = firstAlert.staticTexts.allElementsBoundByIndex.map(\.label).joined(separator: "\n") /// GeneXus' msg function may split the text if it has several lines
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
			guard let control = _findElement(.controlName(controlName), context: context, elementTypes: _allElementTypes) else {
				XCTFail("Could not find control with name '\(controlName)'")
				return
			}
			rows = control.children(matching: .cell).matching(NSPredicate(format: "identifier != %@", GXAccessibilityTag.loadingCell.tagString)).count
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
				XCTFail("Specified button not found in \(alertType ?? "alert")")
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
			let baseDescription = target.map { "\(action) '\($0)'" } ?? action
			return context.map { "\(baseDescription) at '\($0)'" } ?? baseDescription
		}()
		XCTContext.runActivity(named: activityDescription) { _ in
			activityBlock()
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
		let doneButton = XCUIApplication().navigationBars.buttons.matching(identifier: "Done").firstMatch
		guard doneButton.exists else {
			XCTFail("Could not find navigation bar button Done")
			return
		}
		doneButton.tap()
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
		return datePicker.buttons.firstMatch.exists
	}
	
	private func findDatePicker(name controlName: String, context: String?) -> XCUIElement? {
		guard let datePicker = _findElement(.controlName(controlName), context: context, elementTypes: [.datePicker]) else { return nil }
		
		if (isInline(datePicker: datePicker)) {
			return datePicker
		}
		else {
			// if the date picker is not inline, a tap is needed to display the "real" picker
			datePicker.tap()
			
			// the "real" picker is always the first one
			return XCUIApplication().datePickers.firstMatch
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
		case .staticText, .button:
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
			let receivedNoNewlines = received.replacingOccurrences(of: "\n", with: " ")
			let expectedNoNewlines = expected.replacingOccurrences(of: "\n", with: " ")
			return receivedNoNewlines == expectedNoNewlines
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
																	.collectionView,
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
																		.collectionView,
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
	guard !name.isEmpty else { return name }
	let head = name.prefix(1).uppercased()
	let tail = name.dropFirst().lowercased()
	return head + tail
}

fileprivate func _findContextElement(_ context: String?, root: XCUIElement = XCUIApplication(), controlRootElement: Bool = true) -> XCUIElement? {
	guard let context = context else {
		return root
	}
	
	let components = context.components(separatedBy: CharacterSet(charactersIn: "."))
	var searchRoot = root
	for component in components.enumerated() {
		if let itemIndex = _findItemIndex(in: component.element) {
			if itemIndex > 0 && itemIndex <= searchRoot.cells.count {
				searchRoot = searchRoot.cells.element(boundBy: itemIndex-1)
			}
			else {
				break;
			}
		}
		else {
			// control name expression
			let componentControlRootElement = controlRootElement && component.offset == components.count - 1
			let controlSearchId = ElementSearchIdentifier.controlName(component.element, root: componentControlRootElement)
			guard let controlElement = _findElement(controlSearchId, searchRoot: searchRoot, timeout: 0) else {
				break
			}
			searchRoot = controlElement
		}
	}
	return searchRoot
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

fileprivate enum ElementSearchIdentifier {
	case controlName(String, root: Bool = false)
	case visibleText(String)
	
	var predicate: NSPredicate {
		switch self {
		case .controlName(let controlName, root: let controlRootElement):
			let controlId = _applyControlNameCasing(controlName)
			guard controlRootElement else {
				return NSPredicate(format: "identifier = %@", controlId)
			}
			let controlRootId = controlId.appending(GXAccessibilityTag.root.tagString)
			let identifiers = [controlRootId, controlId]
			return NSPredicate(format: "identifier IN %@", identifiers)
		case .visibleText(let text):
			let predicateTemplate = NSPredicate(format: "label = $text OR value = $text OR title = $text OR (placeholderValue = $text AND value = nil)")
			return predicateTemplate.withSubstitutionVariables(["text": text])
		}
	}
	
	static func target(_ target: String, controlRootElement: Bool = false) -> [ElementSearchIdentifier] {
		[.controlName(target, root: controlRootElement), .visibleText(target)]
	}
}

fileprivate let DEFAULT_ELEMENT_EXISTANCE_TIMEOUT: TimeInterval = 30
fileprivate let DEFAULT_ELEMENT_NON_EXISTANCE_TIMEOUT: TimeInterval = 1

fileprivate func _findElement(_ searchId: ElementSearchIdentifier,
							  context: String?,
							  includingContextElement: Bool = false,
							  elementTypes: Array<XCUIElement.ElementType> = _anyElementTypes,
							  disambiguateUsing disambiguator: (([XCUIElement]) -> XCUIElement?)? = nil,
							  timeout: TimeInterval = DEFAULT_ELEMENT_EXISTANCE_TIMEOUT) -> XCUIElement? {
	_findElement([searchId], context: context, includingContextElement: includingContextElement, elementTypes: elementTypes, disambiguateUsing: disambiguator, timeout: timeout)
}

fileprivate func _findElement(_ searchIds: [ElementSearchIdentifier],
							  context: String?,
							  includingContextElement: Bool = false,
							  elementTypes: Array<XCUIElement.ElementType> = _anyElementTypes,
							  disambiguateUsing disambiguator: (([XCUIElement]) -> XCUIElement?)? = nil,
							  timeout: TimeInterval = DEFAULT_ELEMENT_EXISTANCE_TIMEOUT) -> XCUIElement? {
	if context == "applicationbar" {
		return _findApplicationBarElement(searchIds, elementTypes: elementTypes, timeout: timeout)
	}
	
	guard var searchRoot = _findContextElement(context) else {
		return nil
	}
	
	var includingSearchRoot: Bool = context != nil
	let modalAlert = searchRoot.alerts.firstMatch
	if modalAlert.exists {
		searchRoot = modalAlert
		includingSearchRoot = false
	}
	
	return _findElement(searchIds, searchRoot: searchRoot, includingSearchRoot: includingSearchRoot, elementTypes: elementTypes, disambiguateUsing: disambiguator, timeout: timeout)
}

fileprivate func _findElement(_ searchId: ElementSearchIdentifier,
							  searchRoot: XCUIElement,
							  includingSearchRoot: Bool = false,
							  elementTypes: Array<XCUIElement.ElementType> = _anyElementTypes,
							  disambiguateUsing disambiguator: (([XCUIElement]) -> XCUIElement?)? = nil,
							  timeout: TimeInterval = DEFAULT_ELEMENT_EXISTANCE_TIMEOUT) -> XCUIElement? {
	_findElement([searchId], searchRoot: searchRoot, includingSearchRoot: includingSearchRoot, elementTypes: elementTypes, disambiguateUsing: disambiguator, timeout: timeout)
}

fileprivate func _findElement(_ searchIds: [ElementSearchIdentifier],
							  searchRoot: XCUIElement,
							  includingSearchRoot: Bool = false,
							  elementTypes: Array<XCUIElement.ElementType> = _anyElementTypes,
							  disambiguateUsing disambiguator: (([XCUIElement]) -> XCUIElement?)? = nil,
							  timeout: TimeInterval = DEFAULT_ELEMENT_EXISTANCE_TIMEOUT) -> XCUIElement? {
	_findElement(searchIds, searchRoot: .first((element: searchRoot, includingSearchRootElement: includingSearchRoot)), elementTypes: elementTypes, disambiguateUsing: disambiguator, timeout: timeout)
}

fileprivate func _findElement(_ searchIds: [ElementSearchIdentifier],
							  searchRoot: GXEither<(element: XCUIElement, includingSearchRootElement: Bool), XCUIElementQuery>,
							  elementTypes: Array<XCUIElement.ElementType> = _anyElementTypes,
							  disambiguateUsing disambiguator: (([XCUIElement]) -> XCUIElement?)? = nil,
							  timeout: TimeInterval = DEFAULT_ELEMENT_EXISTANCE_TIMEOUT) -> XCUIElement? {
	
	guard !elementTypes.isEmpty, !searchIds.isEmpty else {
		return nil
	}
	let searchIdsPredicate: NSPredicate
	if searchIds.count == 1 {
		searchIdsPredicate = searchIds[0].predicate
	}
	else {
		searchIdsPredicate = NSCompoundPredicate(type: .or, subpredicates: searchIds.map(\.predicate))
	}
	lazy var elementTypePredicate = NSPredicate(format: "elementType IN %@", argumentArray: [elementTypes.map(\.rawValue)])
	if case .first(let searchRoot) = searchRoot, searchRoot.includingSearchRootElement {
		let searchRootElementPredicate = elementTypes == _anyElementTypes ? searchIdsPredicate : NSCompoundPredicate(type: .and, subpredicates: [elementTypePredicate, searchIdsPredicate])
		if searchRootElementPredicate.evaluate(with: searchRoot.element) {
			return searchRoot.element
		}
	}
	let elementTypeQuery: XCUIElementQuery = {
		let singleElementType = elementTypes.count == 1 ? elementTypes[0] : nil
		let searchRootDescendantsQuery: XCUIElementQuery
		switch searchRoot {
		case .first(let searchRoot):
			searchRootDescendantsQuery = searchRoot.element.descendants(matching: singleElementType ?? .any)
		case .second(let searchRootQuery):
			searchRootDescendantsQuery = searchRootQuery.descendants(matching: singleElementType ?? .any)
		}
		guard singleElementType == nil else {
			return searchRootDescendantsQuery
		}
		return searchRootDescendantsQuery.matching(elementTypePredicate)
	}()
	let matchingQuery = elementTypeQuery.matching(searchIdsPredicate)
	let firstMatchingElement = matchingQuery.firstMatch
	if let disambiguator {
		let allMatchingElements = matchingQuery.allElementsBoundByIndex
		if !allMatchingElements.isEmpty {
			return disambiguator(allMatchingElements)
		}
	}
	else {
		if firstMatchingElement.exists {
			return firstMatchingElement
		}
	}
	if timeout > 0 {
		if firstMatchingElement.waitForExistence(timeout: timeout) {
			if let disambiguator {
				let allMatchingElements = matchingQuery.allElementsBoundByIndex
				if !allMatchingElements.isEmpty {
					return disambiguator(allMatchingElements)
				}
			}
			else {
				return firstMatchingElement
			}
		}
	}
	return nil
}

fileprivate func _elementTypeDisambiguator(for elementTypes: Array<XCUIElement.ElementType>) -> (([XCUIElement]) -> XCUIElement?)? {
	guard elementTypes.count > 1 else { return nil }
	return { elements in
		guard elements.count > 1 else { return elements.first }
		func elementTypeIndex(of element: XCUIElement) -> Int? {
			elementTypes.firstIndex(of: element.elementType)
		}
		return elements.reduce(nil as (element: XCUIElement, elementTypeIndex: Int)?) { partialResult, element in
			guard let elementTypeIndex = elementTypeIndex(of: element) else {
				return partialResult
			}
			guard let partialResult, partialResult.elementTypeIndex <= elementTypeIndex else {
				return (element, elementTypeIndex)
			}
			return partialResult
		}?.element
	}
}

fileprivate enum GXAccessibilityTag: String {
	case root = "Root"
	case loadingCell = "LoadingCell"
	case moreAction = "MoreAction"
	
	var tagString: String {
		":-gx:\(self.rawValue):-:"
	}
}

fileprivate func _applicationBarQuery() -> XCUIElementQuery {
	let barsElementTypes: [XCUIElement.ElementType] = [.navigationBar, .toolbar]
	let barsPredicate = NSPredicate(format: "elementType IN %@", argumentArray: [barsElementTypes.map(\.rawValue)])
	return XCUIApplication().descendants(matching: .any).matching(barsPredicate)
}

fileprivate func _findApplicationBarElement(_ searchIds: [ElementSearchIdentifier],
											elementTypes: Array<XCUIElement.ElementType> = _anyElementTypes,
											timeout: TimeInterval = DEFAULT_ELEMENT_EXISTANCE_TIMEOUT) -> XCUIElement? {
	let appBar = _applicationBarQuery()
	var controlElement = _findElement(searchIds, searchRoot: .second(appBar), elementTypes: elementTypes, timeout: 0)
	if controlElement == nil {
		/// Low priority actions may not be present directly on screen, they may appear in an action sheet after tapping the "more" button
		let moreActionsButton = appBar.descendants(matching: .button).matching(identifier: GXAccessibilityTag.moreAction.tagString).firstMatch
		if moreActionsButton.exists {
			moreActionsButton.tap()
			let sheetElement = XCUIApplication().sheets.firstMatch
			if sheetElement.exists {
				controlElement = _findElement(searchIds, searchRoot: sheetElement, elementTypes: elementTypes, timeout: 0)
			}
		}
		if controlElement == nil, timeout > 0 {
			/// Retry with timeout if not found in Low priority actions
			controlElement = _findElement(searchIds, searchRoot: .second(appBar), elementTypes: elementTypes, timeout: timeout)
		}
	}
	return controlElement
}
