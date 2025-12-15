//
//  VisualTestingProvider.swift
//
//
//  Created by José Echagüe on 10/1/23.
//

import Foundation
import GXFoundation
import GXObjectsModel

internal class VisualTestingProvider {
	
	enum VisualTestingError: Error, Equatable {
		static func == (lhs: VisualTestingProvider.VisualTestingError, rhs: VisualTestingProvider.VisualTestingError) -> Bool {
			switch lhs {
			case .invalidURL:
				return if case .invalidURL = rhs { true } else { false }
			case .failedToUploadImage:
				return if case .failedToUploadImage = rhs { true } else { false }
			case .couldNotSerializeParameters:
				return if case .couldNotSerializeParameters = rhs { true } else { false }
			case .network(let lhsInnerError):
				guard case .network(let rhsInnerError) = rhs else { return false }
				return (lhsInnerError as NSError) == (rhsInnerError as NSError)
			}
		}
		
		case invalidURL
		case failedToUploadImage
		case couldNotSerializeParameters
		case network(innerError: Error)
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
	
	// MARK: Init
	
	init(projectCode: String, testName: String, reference: String, serverProvider: VisualTestingServerProvider) {
		self.projectCode = projectCode
		self.testName = testName
		self.reference = reference
		self.serverProvider = serverProvider
	}
	
	// MARK: Public API
	
	func getReferenceImage() throws(VisualTestingError) -> UIImage? {
		guard let requestURL = getResourceURL else { throw .invalidURL }
		let paramsData: Data
		do {
			paramsData = try JSONSerialization.data(withJSONObject: baseParameters)
		}
		catch {
			throw .couldNotSerializeParameters
		}
		let postResult: [String: Any] = try awaitPost(toURL: requestURL, data: paramsData, mimeType: "application/json")
		guard let imageURLString = postResult["image"] as? String, !imageURLString.isEmpty else {
			return nil
		}
		return try getImage(from: imageURLString)
	}
	
	func saveReferenceImage(image: UIImage) throws(VisualTestingError) -> String? {
		guard let requestURL = setResourceURL else { throw .invalidURL }
		let gxuploadCode = try uploadImage(image: image)
		var params = baseParameters
		params["image"] = gxuploadCode
		let paramsData: Data
		do {
			paramsData = try JSONSerialization.data(withJSONObject: params)
		}
		catch {
			throw .couldNotSerializeParameters
		}
		let postResult: [String: Any] = try awaitPost(toURL: requestURL, data: paramsData, mimeType: "application/json", emptyDataResponse: [:])
		return GXUtilities.string(from: postResult["diffId"])
	}
	
	func saveImageWithDifference(image: UIImage) throws(VisualTestingError) -> String? {
		// Use the same service used to save a new reference image
		try self.saveReferenceImage(image: image)
	}
	
	// MARK: - Private
	
	private func getImage(from urlString: String) throws(VisualTestingError) -> UIImage {
		guard let url = URL(string: urlString) else {
			throw .couldNotSerializeParameters
		}
		let resultData: Data = try awaitRequest(URLRequest(url: url))
		guard let image = UIImage(data: resultData) else {
			throw .network(innerError: NSError.defaultGXError(withDeveloperDescription: "Invalid Image Data"))
		}
		return image
	}
	
	private func uploadImage(image: UIImage) throws(VisualTestingError) -> String {
		guard let requestURL = imageUploadURL else { throw .invalidURL }
		guard let pngData = image.rotatedPngData() else {
			throw .failedToUploadImage
		}
		let response: [String: Any]
		do {
			response = try awaitPost(toURL: requestURL, data: pngData, mimeType: "image/png", emptyDataResponse: [:])
		}
		catch {
			throw .failedToUploadImage
		}
		guard let objectID = response["object_id"] as? String else {
			throw .failedToUploadImage
		}
		return objectID
	}
	
	// MARK: Network
	
	private var baseURLString: String? {
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
	
	private var baseParameters: [String: Any] {
		[
			"projectCode": projectCode,
			"testCode": testName,
			"resourceReference": reference,
			"platform": Platform.iOS.rawValue
		]
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
	
	private func awaitRequest<ResponseType>(_ request: URLRequest, emptyDataResponse: ResponseType? = nil) throws(VisualTestingError) -> ResponseType {
		var result: Result<ResponseType, VisualTestingError>! = nil
		let dGroup = DispatchGroup()
		dGroup.enter()
		let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
			defer { dGroup.leave() }
			do {
				if let error {
					throw error
				}
				guard let httpResponse = response as? HTTPURLResponse else {
					throw NSError.defaultGXError(withDeveloperDescription: "Invalid response from server")
				}
				guard httpResponse.statusCode >= 200, httpResponse.statusCode < 300 else {
					throw NSError(HTTPURLResponseStatusCode: httpResponse.statusCode, failingURL: response?.url)
				}
				guard ResponseType.self != Void.self else {
					result = (Result<Void, VisualTestingError>.success(()) as! Result<ResponseType, VisualTestingError>)
					return
				}
				guard let data else {
					throw NSError.defaultGXError(withDeveloperDescription: "No data returned from server")
				}
				guard ResponseType.self != Data.self else {
					result = (Result<Data, VisualTestingError>.success(data) as! Result<ResponseType, VisualTestingError>)
					return
				}
				if data.isEmpty, let emptyDataResponse {
					result = .success(emptyDataResponse)
					return
				}
				guard let json = try JSONSerialization.jsonObject(with: data) as? ResponseType else {
					throw NSError.defaultGXError(withDeveloperDescription: "Invalid JSON response returned from server")
				}
				result = .success(json)
			}
			catch {
				result = .failure(.network(innerError: error))
			}
		})
		task.resume()
		dGroup.wait()
		return try result.get()
	}
	
	private func awaitPost<ResponseType>(toURL requestURL: URL, data: Data, mimeType: String, emptyDataResponse: ResponseType? = nil) throws(VisualTestingError) -> ResponseType {
		let request = postRequest(forURL: requestURL, data: data, mimeType: mimeType)
		return try awaitRequest(request, emptyDataResponse: emptyDataResponse)
	}
}
