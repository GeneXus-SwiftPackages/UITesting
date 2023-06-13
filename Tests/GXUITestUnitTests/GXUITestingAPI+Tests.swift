//
//  GXUITestingAPI+Tests.swift
//
//
//  Created by José Echagüe on 6/10/23.
//

import XCTest

@testable import GXUITest

public class GXUITestUnitTests : XCTestCase {
	public func test_SameImage() throws {
		let image = try XCTUnwrap(UIImage(named: "expectedImage_1", in: Bundle.module, compatibleWith: nil))
		let expectedImage = CIImage(cgImage: try XCTUnwrap(image.cgImage))
		
		let comparisonResult = try image.perceptuallyCompare(to: expectedImage)
		
		XCTAssertTrue(comparisonResult)
	}
	
	// These are images that are equal to the human eye but have high DeltaE difference (~10) in a very small numer of pixels (< 0.1 %)
	// Default perceptual Comparison should match them
	public func test_SimilarImages() throws {
		for imageIndex in 1...2 {
			let expectedImage = try XCTUnwrap(UIImage(named: "expectedImage_\(imageIndex)", in: Bundle.module, compatibleWith: nil))
			let expectedCIImage = CIImage(cgImage: expectedImage.cgImage!)
			
			let comparisonImage = try XCTUnwrap(UIImage(named: "comparisonImage_\(imageIndex)", in: Bundle.module, compatibleWith: nil))
			
			let comparisonResult = try comparisonImage.perceptuallyCompare(to: expectedCIImage, pixelPrecision: 0.999, perceptualPrecision: 0.999)
			
			XCTAssertTrue(comparisonResult)
		}
	}
}
