//
//  UIImage+Tests.swift
//
//
//  Created by José Echagüe on 10/10/23.
//

import Testing

@testable import GXUITest

struct UIImage_Tests {
	@Test func rotatedPngData_downOrientation() throws {
		let image = try #require(UIImage(named: "expectedImage_3", in: Bundle.module, compatibleWith: nil),
								  "Unable to load image for test from xcassets")
		let rotatedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .down)
		
		let pngData = try #require(rotatedImage.rotatedPngData())
		let imageFromData = try #require(UIImage(data: pngData))
		
		#expect(rotatedImage.size == imageFromData.size)
		#expect(try rotatedImage.perceptuallyCompare(toFiduciary: imageFromData, pixelPrecision: 1.0, perceptualPrecision: 1.0) == false)
	}
	
	@Test func rotatedPngData_upOrientation() throws {
		let image = try #require(UIImage(named: "expectedImage_3", in: Bundle.module, compatibleWith: nil),
								  "Unable to load image for test from xcassets")
		
		let rotatedPngData = try #require(image.rotatedPngData())
		let pngData = try #require(image.pngData())
		
		#expect(rotatedPngData == pngData)
	}
	
	@Test func rotatedPngData_Idempotency() throws {
		let image = try #require(UIImage(named: "expectedImage_3", in: Bundle.module, compatibleWith: nil),
								  "Unable to load image for test from xcassets")
		let rotatedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .down)
		
		let singleRotationPngData = try #require(rotatedImage.rotatedPngData())
		let singleRotationImage = try #require(UIImage(data: singleRotationPngData))
		
		let doubleRotationImage = UIImage(cgImage: singleRotationImage.cgImage!, scale: image.scale, orientation: .down)
		let doubleRotationPngData = try #require(doubleRotationImage.rotatedPngData())
		
		let resultingImage = try #require(UIImage(data: doubleRotationPngData))
		
		#expect(rotatedImage.size == resultingImage.size)
		#expect(try rotatedImage.perceptuallyCompare(toFiduciary: resultingImage, pixelPrecision: 1.0, perceptualPrecision: 1.0))
	}
}
