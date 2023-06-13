//
//  UIImage+ImageComparison.swift
//  
//
//  Created by José Echagüe on 6/11/23.
//

/* Adapted from https://github.com/pointfreeco/swift-snapshot-testing
 
 Original license below:
 
 MIT License
 Copyright (c) 2019 Point-Free, Inc.
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */
 
import CoreImage.CIKernel
import MetalPerformanceShaders
import UIKit

private let DELTA_E_THRESHOLD = 1 - 0.01 // DeltaE < 1: No perceptible difference to human eyes.
private let PIXEL_THRESHOLD = 1 - 0.001 // At least 99.9% of pixels must match

extension UIImage {
	
	func perceptuallyCompare(to fiduciaryImage: CIImage, pixelPrecision: Float = Float(PIXEL_THRESHOLD), perceptualPrecision: Float = Float(DELTA_E_THRESHOLD)) throws -> Bool {
		return try self.perceptuallyCompare(toFiduciary: fiduciaryImage, pixelPrecision: Double(pixelPrecision), perceptualPrecision: Double(perceptualPrecision))
	}
	
	func perceptuallyCompare(toFiduciary fiduciary: UIImage, pixelPrecision: Double = PIXEL_THRESHOLD, perceptualPrecision: Double = DELTA_E_THRESHOLD) throws -> Bool {
		return try perceptuallyCompare(toFiduciary: try fiduciary.nonOptionalCIImage(), pixelPrecision: pixelPrecision, perceptualPrecision: perceptualPrecision)
	}
}

private extension UIImage {
	func perceptuallyCompare(toFiduciary fiduciary: CIImage, pixelPrecision: Double = PIXEL_THRESHOLD, perceptualPrecision: Double = DELTA_E_THRESHOLD) throws -> Bool {
		let rawDeltaE = try self.cie94(fiduciary: fiduciary)
		let thresholdedDeltaE = try rawDeltaE.thresholdedImage(threshold: perceptualPrecision)
		
		let context = CIContext(options: [.workingColorSpace: NSNull(), .outputColorSpace: NSNull()])
		
		let averagePixel = thresholdedDeltaE.averagePixelValue(withContext: context)
		let actualPixelPrecision = 1 - averagePixel
		
		guard actualPixelPrecision < pixelPrecision else { return true }
		
		let maximumDeltaE = rawDeltaE.maximumPixelValue(withContext: context)
		let actualPerceptualPrecision = 1 - maximumDeltaE / 100
		
		return actualPerceptualPrecision >= perceptualPrecision
	}
	
	func cie94(fiduciary: CIImage) throws -> CIImage {
		let ciImage = try self.nonOptionalCIImage()
		
		// CILabDeltaE uses CIE94
		return ciImage.applyingFilter("CILabDeltaE", parameters: ["inputImage2": fiduciary])
	}
	
	func nonOptionalCIImage() throws -> CIImage {
		guard let ciImage = self.ciImage ?? CoreImage.CIImage(image: self) else {
			throw GXUITestError.runtimeError("Unable to obtain CIImage from current image")
		}
			
		return ciImage
	}
}

private extension CIImage {
	func thresholdedImage(threshold: Double) throws -> CIImage {
		var threasholdedImage: CIImage
		do {
			threasholdedImage = try ThresholdImageProcessorKernel.apply(
				withExtent: self.extent,
				inputs: [self],
				arguments: [ThresholdImageProcessorKernel.inputThresholdKey: (1 - threshold) * 100]
			)
		} catch {
			throw GXUITestError.runtimeError(error.localizedDescription)
		}
		
		return threasholdedImage
	}
	
	func averagePixelValue(withContext context: CIContext) -> Double {
		var averagePixelValue: Double = 0
		context.render(
		  self.applyingFilter("CIAreaAverage", parameters: [kCIInputExtentKey: self.extent]),
		  toBitmap: &averagePixelValue,
		  rowBytes: MemoryLayout<Double>.size,
		  bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
		  format: .Rf,
		  colorSpace: nil
		)
		
		return averagePixelValue
	}
	
	func maximumPixelValue(withContext context: CIContext) -> Double {
		var maximumPixelValue: Double = 0
		context.render(
			self.applyingFilter("CIAreaMaximum", parameters: [kCIInputExtentKey: self.extent]),
			toBitmap: &maximumPixelValue,
			rowBytes: MemoryLayout<Double>.size,
			bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
			format: .Rf,
			colorSpace: nil
		)
		
		return maximumPixelValue
	}
}

// Copied from https://developer.apple.com/documentation/coreimage/ciimageprocessorkernel
private final class ThresholdImageProcessorKernel: CIImageProcessorKernel {
	static let inputThresholdKey = "thresholdValue"
	static let device = MTLCreateSystemDefaultDevice()
	
	override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
		guard
			let device = device,
			let commandBuffer = output.metalCommandBuffer,
			let input = inputs?.first,
			let sourceTexture = input.metalTexture,
			let destinationTexture = output.metalTexture,
			let thresholdValue = arguments?[inputThresholdKey] as? Float else {
			return
		}
		
		let threshold = MPSImageThresholdBinary(
			device: device,
			thresholdValue: thresholdValue,
			maximumValue: 1.0,
			linearGrayColorTransform: nil
		)
		
		threshold.encode(
			commandBuffer: commandBuffer,
			sourceTexture: sourceTexture,
			destinationTexture: destinationTexture
		)
	}
}
