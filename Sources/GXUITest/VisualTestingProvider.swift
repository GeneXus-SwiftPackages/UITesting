//
//  VisualTestingProvider.swift
//
//
//  Created by José Echagüe on 10/1/23.
//

import Foundation
import GXObjectsModel

internal class VisualTestingProvider {
	
	enum VisualTestingError: Error {
		case invalidURL
		case failedToUploadImage
		case couldNotSerializeParameters
	}
	
	enum Platform: Int {
		case iOS = 1
		case Android = 2
	}
	
	// MARK: Properties
	
	let projectCode: String
	let testName: String
	let reference: String
	
	private let serverProvider: VisualTestingServerProvider
	
	var baseURLString: String? {
		let baseURL = type(of: serverProvider).visualTestingServer
		
		guard !baseURL.isEmpty else { return nil }
		
		let separator = baseURL.hasSuffix("/") ? "" : "/"
		return "\(baseURL)\(separator)"
	}

	private var getResourceURL: URL? {
		guard let baseURLString else { return nil }
		
		return URL(string: "\(baseURLString)GetResource")
	}

	private var setResourceURL: URL? {
		guard let baseURLString else { return nil }
		
		return URL(string: "\(baseURLString)SetResource")
	}
	
	private var imageUploadURL: URL? {
		guard let baseURLString else { return nil }
		
		return URL(string: "\(baseURLString)SetResource/gxobject")
	}

	// MARK: Init
	
	init(projectCode: String, testName: String, reference: String, serverProvider: VisualTestingServerProvider) {
		self.projectCode = projectCode
		self.testName = testName
		self.reference = reference
		
		self.serverProvider = serverProvider
	}
	
	// MARK: Public API
	
	func getReferenceImage() throws -> UIImage? {
		guard let requestURL = getResourceURL else {
			throw VisualTestingError.invalidURL
		}
		
		let params: Dictionary<String, Any> = ["projectCode": projectCode,
											   "testCode": testName,
											   "resourceReference": reference,
											   "platform": Platform.iOS.rawValue]
		
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
		// Use the same service used to save a new reference image
		try self.saveReferenceImage(image: image)
	}
	
	// MARK: - Private
	
	private func getImage(from urlString: String) -> UIImage? {
		guard let url = URL(string: urlString),
			  let resultData = awaitGet(fromURL: url) else {
			return nil
		}
		
		return UIImage(data: resultData)
	}
	
	private func uploadImage(image: UIImage) throws -> String? {
		guard let requestURL = imageUploadURL else { throw VisualTestingError.invalidURL }
		
		guard let pngData = image.rotatedPngData() else { return nil }
		
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
		
		request.setGXClientInfoHTTPHeaderFields(for: GXModelForTesting.shared)
		
		request.addValue(mimeType, forHTTPHeaderField: "Content-Type")
		request.addValue(GXUtilities.deviceName(), forHTTPHeaderField: "DeviceName")
		
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
