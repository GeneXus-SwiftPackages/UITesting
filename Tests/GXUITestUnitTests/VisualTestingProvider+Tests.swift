//
//  VisualTestingProvider+Tests.swift
//
//
//  Created by José Echagüe on 10/2/23.
//

import XCTest
import OHHTTPStubs
import OHHTTPStubsSwift

@testable import GXUITest

class VisualTestingProvider_Tests_ProviderWithoutURL : XCTestCase {
	class EmtpyURLServerProvider : VisualTestingServerProvider {
		static var visualTestingServer: String { "" }
	}
	
	let provider = VisualTestingProvider(projectCode: "ABC", testName: "Test123", reference: "Resouce reference", serverProvider: EmtpyURLServerProvider())
	
	func test_GetResource() {
		XCTAssertThrowsError(try provider.getReferenceImage()) { error in
			XCTAssertEqual(error as! VisualTestingProvider.VisualTestingError, VisualTestingProvider.VisualTestingError.invalidURL)
		}
	}
	
	func test_SaveResouce() {
		guard let image = TestHelpers.generateRandomImage() else {
			XCTFail("Unable to generate image for test")
			return
		}
		
		XCTAssertThrowsError(try provider.saveReferenceImage(image: image)) { error in
			XCTAssertEqual(error as! VisualTestingProvider.VisualTestingError, VisualTestingProvider.VisualTestingError.invalidURL)
		}
	}
	
	func test_SaveDifference() {
		guard let image = TestHelpers.generateRandomImage() else {
			XCTFail("Unable to generate image for test")
			return
		}
		
		XCTAssertThrowsError(try provider.saveImageWithDifference(image: image)) { error in
			XCTAssertEqual(error as! VisualTestingProvider.VisualTestingError, VisualTestingProvider.VisualTestingError.invalidURL)
		}
	}
}

class VisualTestingProvider_Tests_ProviderWithURL : XCTestCase {
	class ExampleURLServerProvider : VisualTestingServerProvider {
		static var visualTestingServer: String { "http://example.com" }
	}
	
	let provider =  VisualTestingProvider(projectCode: "ABC", testName: "Test123", reference: "Resouce reference", serverProvider: ExampleURLServerProvider())
	
	func test_GetResource() throws {
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
			
			let responseBody = ["image": "http://example.com/image.png"]
			guard let responseData = try? JSONSerialization.data(withJSONObject: responseBody, options: []) else {
				return TestHelpers.fail(with: "Failed to construct response body")
			}
			
			return HTTPStubsResponse(data: responseData,
									 statusCode: 200,
									 headers: ["Content-Type":"application/json"])
		}
		
		stub(condition: isAbsoluteURLString("http://example.com/image.png")) { request in
			guard let randomImage = TestHelpers.generateRandomImage(),
				  let pngImageData = randomImage.rotatedPngData() else {
				return TestHelpers.fail(with: "Unable to generate image for response")
			}
			
			return HTTPStubsResponse(data: pngImageData,
									 statusCode: 200,
									 headers: ["Content-Type":"image/png"])
		}
		
		let referenceImage = try provider.getReferenceImage()
		
		XCTAssertNotNil(referenceImage)
	}
	
	func test_SaveResource() throws {
		guard let image = TestHelpers.generateRandomImage() else {
			XCTFail("Unable to generate image for test")
			return
		}
		
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
			
			XCTAssertTrue(TestHelpers.isPNGImageData(body), "Image representation is not that of a valid PNG image")
			
			let responseBody = ["object_id": uploadedObjectID]
			guard let responseData = try? JSONSerialization.data(withJSONObject: responseBody, options: []) else {
				return TestHelpers.fail(with: "Failed to construct response body")
			}
			
			return HTTPStubsResponse(data: responseData, statusCode: 200, headers: nil)
		}
		
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
			XCTAssertEqual(bodyParams["image"] as? String, uploadedObjectID)
			
			return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
		}
		
		XCTAssertNoThrow(try provider.saveReferenceImage(image: image))
	}
	
	private func assertCommonParameters(in requestBody: [String : Any])  {
		XCTAssertEqual(requestBody["projectCode"] as? String, provider.projectCode)
		XCTAssertEqual(requestBody["resourceReference"] as? String, provider.reference)
		XCTAssertEqual(requestBody["testCode"] as? String, provider.testName)
		
		XCTAssertEqual(requestBody["platform"] as? Int, VisualTestingProvider.Platform.iOS.rawValue)
	}
	
	private func assertCommonHeaders(in requestHeaders: [String : String]?, contentType: String = "application/json") {
		guard let requestHeaders else {
			XCTFail("Request dictionary should not be nil")
			return
		}
		
		XCTAssertEqual(requestHeaders["Content-Type"], contentType)
		
		XCTAssertNotNil(requestHeaders["Accept-Language"])
		XCTAssertNotNil(requestHeaders["DeviceName"])
		XCTAssertNotNil(requestHeaders["DeviceOSName"])
		XCTAssertNotNil(requestHeaders["DeviceOSVersion"])
		XCTAssertNotNil(requestHeaders["DeviceType"])
		XCTAssertNotNil(requestHeaders["GeneXus-Agent"])
		XCTAssertNotNil(requestHeaders["GxTZOffset"])
	}
}

class TestHelpers {
	static func fail(with message: String,
					 response: HTTPStubsResponse = HTTPStubsResponse.genericClientErrorResponse) -> HTTPStubsResponse {
		XCTFail(message)
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
		guard let contentLength = try? XCTUnwrap(request.value(forHTTPHeaderField: "Content-Length")) else {
			return .failure(self.fail(with: "Unable to read Content-Lenght from headers"))
		}
		
		guard let bufferSize = try? XCTUnwrap(Int(contentLength)) else {
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
		
		guard let bodyParams = try? JSONSerialization.jsonObject(with: body, options: []) as? [String: Any] else {
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

extension HTTPStubsResponse: @unchecked Sendable { }
extension HTTPStubsResponse : @retroactive Error { }

private extension HTTPStubsResponse {
	static var genericClientErrorResponse : HTTPStubsResponse {
		HTTPStubsResponse(data: Data(), statusCode: 400, headers: nil)
	}
}
