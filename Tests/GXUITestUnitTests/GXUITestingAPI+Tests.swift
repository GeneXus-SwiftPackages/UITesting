//
//  GXUITestingAPI+Tests.swift
//
//
//  Created by José Echagüe on 6/10/23.
//

import Testing

@testable import GXUITest

struct GXUITestUnitTests {
	@Test func sameImage() throws {
		let image = try #require(UIImage(named: "expectedImage_1", in: Bundle.module, compatibleWith: nil))
		let expectedImage = CIImage(cgImage: try #require(image.cgImage))
		
		let comparisonResult = try image.perceptuallyCompare(to: expectedImage)
		
		#expect(comparisonResult)
	}
	
	// These are images that are equal to the human eye but have high DeltaE difference (~10) in a very small numer of pixels (< 0.1 %)
	// Default perceptual Comparison should match them
	@Test func similarImages() throws {
		for imageIndex in 1...2 {
			let expectedImage = try #require(UIImage(named: "expectedImage_\(imageIndex)", in: Bundle.module, compatibleWith: nil))
			let expectedCIImage = CIImage(cgImage: expectedImage.cgImage!)
			
			let comparisonImage = try #require(UIImage(named: "comparisonImage_\(imageIndex)", in: Bundle.module, compatibleWith: nil))
			
			let comparisonResult = try comparisonImage.perceptuallyCompare(to: expectedCIImage, pixelPrecision: 0.999, perceptualPrecision: 0.999)
			
			#expect(comparisonResult)
		}
	}
	
	@Test func completelyDifferentImages() throws {
		let expectedImage = try #require(UIImage(named: "expectedImage_3", in: Bundle.module, compatibleWith: nil))
		let expectedCIImage = CIImage(cgImage: expectedImage.cgImage!)
		
		let comparisonImage = try #require(UIImage(named: "comparisonImage_3", in: Bundle.module, compatibleWith: nil))
		
		let comparisonResult = try comparisonImage.perceptuallyCompare(to: expectedCIImage)
		
		#expect(!comparisonResult)
	}
}
