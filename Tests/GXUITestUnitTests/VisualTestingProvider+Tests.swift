//
//  VisualTestingProvider+Tests.swift
//
//
//  Created by José Echagüe on 10/2/23.
//

import Testing
import OHHTTPStubs
import OHHTTPStubsSwift

@testable import GXUITest

struct VisualTestingProvider_Tests_ProviderWithoutURL {
	class EmtpyURLServerProvider : VisualTestingServerProvider {
		static var visualTestingServer: String { "" }
	}
	
	let provider = VisualTestingProvider(projectCode: "ABC", testName: "Test123", reference: "Resouce reference", serverProvider: EmtpyURLServerProvider())
	
	@Test func getResource() {
		#expect(throws: VisualTestingProvider.VisualTestingError.invalidURL) {
			try provider.getReferenceImage()
		}
	}
	
	@Test func saveResouce() throws {
		let image = try #require(TestHelpers.generateRandomImage(), "Unable to generate image for test")
		#expect(throws: VisualTestingProvider.VisualTestingError.invalidURL) {
			try provider.saveReferenceImage(image: image)
		}
	}
	
	@Test func saveDifference() throws {
		let image = try #require(TestHelpers.generateRandomImage(), "Unable to generate image for test")
		#expect(throws: VisualTestingProvider.VisualTestingError.invalidURL) {
			try provider.saveImageWithDifference(image: image)
		}
	}
}

@Suite(.serialized) final class VisualTestingProvider_Tests_ProviderWithURL {
	class ExampleURLServerProvider : VisualTestingServerProvider {
		static var visualTestingServer: String { "http://example.com" }
	}
	
	let provider =  VisualTestingProvider(projectCode: "ABC", testName: "Test123", reference: "Resouce reference", serverProvider: ExampleURLServerProvider())
	
	deinit {
		HTTPStubs.removeAllStubs()
	}
	
	@Test(arguments: [true, false])
	func getResource(found: Bool) throws {
		let testImageURL = found ? "http://example.com/image.png" : ""
		stub(condition: isAbsoluteURLString("http://example.com/GetResource")) { request in
			self.assertCommonHeaders(in: request.allHTTPHeaderFields)
			
			let bodyParams: [String : Any]
			switch TestHelpers.readObjectFromBody(of: request) {
			case .success(let _bodyParams):
				bodyParams = _bodyParams
				
			case .failure(let errorResponse):
				return errorResponse
			}
			
			self.assertCommonParameters(in: bodyParams)
			
			let responseBody = ["image": testImageURL]
			return HTTPStubsResponse(jsonObject: responseBody,
									 statusCode: 200,
									 headers: ["Content-Type":"application/json"])
		}
		
		if found {
			let testImage = try #require(TestHelpers.generateRandomImage(), "Unable to generate image for response")
			let pngImageData = try #require(testImage.rotatedPngData(), "Unable to generate image data for response")
			stub(condition: isAbsoluteURLString(testImageURL)) { request in
				HTTPStubsResponse(data: pngImageData,
								  statusCode: 200,
								  headers: ["Content-Type":"image/png"])
			}
		}
		
		let referenceImage = try provider.getReferenceImage()
		if found {
			#expect(referenceImage != nil)
		}
		else {
			#expect(referenceImage == nil)
		}
	}
	
	@Test func getResource_networkError() throws {
		stub(condition: isAbsoluteURLString("http://example.com/GetResource")) { request in
			self.assertCommonHeaders(in: request.allHTTPHeaderFields)
			return HTTPStubsResponse.init(data: Data(), statusCode: 500, headers: nil)
		}
		let expectedInnerError = NSError.error(forHTTPURLResponseStatusCode: 500, failingURL: .init(string: "http://example.com/GetResource"))
		#expect(throws: VisualTestingProvider.VisualTestingError.network(innerError: expectedInnerError)) {
			try provider.getReferenceImage()
		}
	}
	
	@Test(arguments: [nil, false, true])
	func saveResource(includeDiffId: Bool?) throws {
		let image = try #require(TestHelpers.generateRandomImage(), "Unable to generate image for test")
		let uploadedObjectID = UUID().uuidString
		stub(condition: isAbsoluteURLString("http://example.com/SetResource/gxobject")) { request in
			self.assertCommonHeaders(in: request.allHTTPHeaderFields, contentType: "image/png")
			
			let body: Data
			switch TestHelpers.readBody(from: request) {
			case .success(let _body):
				body = _body
				
			case .failure(let errorResponse):
				return errorResponse
			}
			
			#expect(TestHelpers.isPNGImageData(body), "Image representation is not that of a valid PNG image")
			
			let responseBody = ["object_id": uploadedObjectID]
			return HTTPStubsResponse(jsonObject: responseBody, statusCode: 200, headers: nil)
		}
		
		let testDiffId = includeDiffId == true ? UUID().uuidString : nil
		stub(condition: isAbsoluteURLString("http://example.com/SetResource")) { request in
			self.assertCommonHeaders(in: request.allHTTPHeaderFields)
			
			let bodyParams: [String : Any]
			switch TestHelpers.readObjectFromBody(of: request) {
			case .success(let _bodyParams):
				bodyParams = _bodyParams
				
			case .failure(let errorResponse):
				return errorResponse
			}
			
			self.assertCommonParameters(in: bodyParams)
			
			// Object ID of uploaded blob
			#expect(bodyParams["image"] as? String == uploadedObjectID)
			if let testDiffId {
				return HTTPStubsResponse(jsonObject: ["diffId": testDiffId], statusCode: 200, headers: nil)
			}
			else {
				return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
			}
		}
		if includeDiffId == nil {
			try provider.saveReferenceImage(image: image)
		}
		else {
			let resultDiffId = try provider.saveImageWithDifference(image: image)
			#expect(resultDiffId == testDiffId)
		}
	}
	
	@Test func saveResource_imageUploadError() throws {
		let image = try #require(TestHelpers.generateRandomImage(), "Unable to generate image for test")
		stub(condition: isAbsoluteURLString("http://example.com/SetResource/gxobject")) { request in
			self.assertCommonHeaders(in: request.allHTTPHeaderFields, contentType: "image/png")
			return HTTPStubsResponse.init(data: Data(), statusCode: 500, headers: nil)
		}
		#expect(throws: VisualTestingProvider.VisualTestingError.failedToUploadImage) {
			try provider.saveReferenceImage(image: image)
		}
	}
	
	private func assertCommonParameters(in requestBody: [String : Any])  {
		#expect(requestBody["projectCode"] as? String == provider.projectCode)
		#expect(requestBody["resourceReference"] as? String == provider.reference)
		#expect(requestBody["testCode"] as? String == provider.testName)
		#expect(requestBody["platform"] as? Int == VisualTestingProvider.Platform.iOS.rawValue)
	}
	
	private func assertCommonHeaders(in requestHeaders: [String : String]?, contentType: String = "application/json") {
		guard let requestHeaders else {
			Issue.record(Comment(rawValue: "Request dictionary should not be nil"))
			return
		}
		#expect(requestHeaders["Content-Type"] == contentType)
		#expect(requestHeaders["Accept-Language"] != nil)
		#expect(requestHeaders["DeviceName"] != nil)
		#expect(requestHeaders["DeviceOSName"] != nil)
		#expect(requestHeaders["DeviceOSVersion"] != nil)
		#expect(requestHeaders["DeviceType"] != nil)
		#expect(requestHeaders["GeneXus-Agent"] != nil)
		#expect(requestHeaders["GxTZOffset"] != nil)
	}
}

class TestHelpers {
	static func fail(with message: String,
					 response: HTTPStubsResponse = HTTPStubsResponse.genericClientErrorResponse) -> HTTPStubsResponse {
		Issue.record(Comment(rawValue: message))
		return response
	}
	
	static func generateRandomImage(imageSize: CGSize = .init(width: 1, height: 1)) -> UIImage? {
		// Function to generate a random color
		func randomColor() -> UIColor {
			let red = CGFloat.random(in: 0.0...1.0)
			let green = CGFloat.random(in: 0.0...1.0)
			let blue = CGFloat.random(in: 0.0...1.0)
			return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
		}
		
		// Create a blank image context
		UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
		defer {
			UIGraphicsEndImageContext()
		}
		
		// Fill the image with random colors
		let context = UIGraphicsGetCurrentContext()
		for x in 0..<Int(imageSize.width) {
			for y in 0..<Int(imageSize.height) {
				let rect = CGRect(x: x, y: y, width: 1, height: 1)
				randomColor().setFill()
				context?.fill(rect)
			}
		}
		
		// Create an UIImage from the context
		return UIGraphicsGetImageFromCurrentImageContext()
	}
	
	static func readBody(from request: URLRequest) -> Result<Data, HTTPStubsResponse> {
		guard let contentLength = request.value(forHTTPHeaderField: "Content-Length") else {
			return .failure(self.fail(with: "Unable to read Content-Lenght from headers"))
		}
		
		guard let bufferSize = Int(contentLength) else {
			return .failure(self.fail(with: "Unable to read an Int value from Content-Lenght header"))
		}
		
		func read(stream: InputStream, bufferSize: Int) -> Data {
			stream.open()
			defer {
				stream.close()
			}
			
			let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
			
			var data = Data()
			while stream.hasBytesAvailable {
				let bytesRead = stream.read(buffer, maxLength: bufferSize)
				guard bytesRead > 0 else { break }
				
				data.append(buffer, count: bytesRead)
			}
			
			return data
		}
		
		guard let httpBodyStream = request.httpBodyStream else {
			return .failure(self.fail(with: "HTTP Body stream should not be nil"))
		}
		
		return .success(read(stream: httpBodyStream, bufferSize: bufferSize))
	}
	
	static func readObjectFromBody(of request: URLRequest) -> Result<[String: Any], HTTPStubsResponse> {
		let body: Data
		switch self.readBody(from: request) {
		case .success(let _body):
			body = _body
			
		case .failure(let errorResponse):
			return .failure(errorResponse)
		}
		
		guard let bodyParams = try? JSONSerialization.jsonObject(with: body) as? [String: Any] else {
			return .failure(self.fail(with: "Failed to read JSON object from request body"))
		}
		
		return .success(bodyParams)
	}
	
	static func isPNGImageData(_ data: Data) -> Bool {
		guard data.count >= 8 else {
			return false // PNG header is at least 8 bytes long
		}
		
		// Check for the PNG magic bytes at the beginning of the data
		let pngHeader: [UInt8] = [137, 80, 78, 71, 13, 10, 26, 10]
		let headerData = Data(pngHeader)
		let headerBytes = [UInt8](data.prefix(8))
		
		return headerData == Data(headerBytes)
	}
}

extension HTTPStubsResponse: @unchecked @retroactive Sendable { }
extension HTTPStubsResponse : @retroactive Error { }

private extension HTTPStubsResponse {
	static var genericClientErrorResponse : HTTPStubsResponse {
		HTTPStubsResponse(data: Data(), statusCode: 400, headers: nil)
	}
}
