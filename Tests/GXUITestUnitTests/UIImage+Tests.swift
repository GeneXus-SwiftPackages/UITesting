//
//  UIImage+Tests.swift
//
//
//  Created by José Echagüe on 10/10/23.
//

import XCTest

@testable import GXUITest

public class UIImage_Tests : XCTestCase {
	public func test_rotatedPngData_downOrientation() throws {
		let image = try XCTUnwrap(UIImage(named: "expectedImage_3", in: Bundle.module, compatibleWith: nil),
								  "Unable to load image for test from xcassets")
		let rotatedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .down)
		
		let pngData = try XCTUnwrap(rotatedImage.rotatedPngData())
		let imageFromData = try XCTUnwrap(UIImage(data: pngData))
		
		XCTAssertEqual(rotatedImage.size, imageFromData.size)
		XCTAssertFalse(try rotatedImage.perceptuallyCompare(toFiduciary: imageFromData, pixelPrecision: 1.0, perceptualPrecision: 1.0))
	}
	
	public func test_rotatedPngData_upOrientation() throws {
		let image = try XCTUnwrap(UIImage(named: "expectedImage_3", in: Bundle.module, compatibleWith: nil),
								  "Unable to load image for test from xcassets")
		
		let rotatedPngData = try XCTUnwrap(image.rotatedPngData())
		let pngData = try XCTUnwrap(image.pngData())
		
		XCTAssertEqual(rotatedPngData, pngData)
	}
	
	public func test_rotatedPngData_Idempotency() throws {
		let image = try XCTUnwrap(UIImage(named: "expectedImage_3", in: Bundle.module, compatibleWith: nil),
								  "Unable to load image for test from xcassets")
		let rotatedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .down)
		
		let singleRotationPngData = try XCTUnwrap(rotatedImage.rotatedPngData())
		let singleRotationImage = try XCTUnwrap(UIImage(data: singleRotationPngData))
		
		let doubleRotationImage = UIImage(cgImage: singleRotationImage.cgImage!, scale: image.scale, orientation: .down)
		let doubleRotationPngData = try XCTUnwrap(doubleRotationImage.rotatedPngData())
		
		let resultingImage = try XCTUnwrap(UIImage(data: doubleRotationPngData))
		
		XCTAssertEqual(rotatedImage.size, resultingImage.size)
		XCTAssertTrue(try rotatedImage.perceptuallyCompare(toFiduciary: resultingImage, pixelPrecision: 1.0, perceptualPrecision: 1.0))
	}
}
