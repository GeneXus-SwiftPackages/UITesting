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
    var resourceDiffId: Int?
	
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

        let params: [String: Any] = [
            "projectCode": projectCode,
            "testCode": testName,
            "resourceReference": reference,
            "platform": Platform.iOS.rawValue
        ]

        guard let paramsData = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return nil
        }

        guard let postResult = awaitPost(
            toURL: requestURL,
            data: paramsData,
            mimeType: "application/json",
            resultKeys: ["image", "diffId"]
        ) else {
            return nil
        }

        if let diffId = postResult["diffId"] as? Int {
            self.resourceDiffId = diffId
            print("diffId received: \(diffId)")
        } else {
            self.resourceDiffId = nil
        }

        guard let imageURL = postResult["image"] as? String else {
            return nil
        }

        return getImage(from: imageURL)
    }

	
    func saveReferenceImage(image: UIImage) throws {
        guard let requestURL = setResourceURL else {
            throw VisualTestingError.invalidURL
        }
        guard let gxuploadCode = try uploadImage(image: image) else {
            throw VisualTestingError.failedToUploadImage
        }

        let params: [String: Any] = [
            "projectCode": projectCode,
            "testCode": testName,
            "resourceReference": reference,
            "platform": Platform.iOS.rawValue,
            "image": gxuploadCode
        ]

        guard let paramsData = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            throw VisualTestingError.couldNotSerializeParameters
        }

        // Using the version of awaitPost that returns multiple keys (object_id, diffId)
        if let response = awaitPost(
            toURL: requestURL,
            data: paramsData,
            mimeType: "application/json",
            resultKeys: ["object_id", "diffId"]
        ) {
            if let objectId = response["object_id"] as? String {
                print("Image uploaded successfully. object_id: \(objectId)")
            }

            if let diffId = response["diffId"] {
                // Handle both Int and String representations
                if let intDiffId = diffId as? Int {
                    self.resourceDiffId = intDiffId
                    print("diffId generated: \(intDiffId)")
                } else if let strDiffId = diffId as? String, let intValue = Int(strDiffId) {
                    self.resourceDiffId = intValue
                    print("diffId generated (converted from string): \(intValue)")
                } else {
                    self.resourceDiffId = nil
                    print("diffId received but could not be interpreted: \(diffId)")
                }
            } else {
                self.resourceDiffId = nil
                print("No diffId was generated for this image.")
            }
        } else {
            self.resourceDiffId = nil
            print("Error uploading the image or receiving the server response.")
        }
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
		
        guard let result = awaitPost(
            toURL: requestURL,
            data: pngData,
            mimeType: "image/png",
            resultKeys: ["object_id"]
        ) else {
            return nil
        }

        return result["object_id"] as? String

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
	
    private func awaitPost(
        toURL requestURL: URL,
        data: Data,
        mimeType: String,
        resultKeys: [String]
    ) -> [String: Any]? {
        
        var result: [String: Any]? = nil
        let request = postRequest(forURL: requestURL, data: data, mimeType: mimeType)
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            
            guard let data = data, !data.isEmpty, error == nil else {
                print("Empty response or error when performing POST: \(String(describing: error))")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    var filteredResult: [String: Any] = [:]
                    
                    for key in resultKeys {
                        filteredResult[key] = json[key]
                    }
                    
                    if let diffId = json["diffId"] {
                        if let intDiffId = diffId as? Int {
                            filteredResult["diffId"] = intDiffId
                        } else if let strDiffId = diffId as? String, let intValue = Int(strDiffId) {
                            filteredResult["diffId"] = intValue
                        } else {
                            filteredResult["diffId"] = diffId
                        }
                    }
                    
                    result = filteredResult
                } else {
                    print("The server response is not valid JSON.")
                }
            } catch {
                print("Error deserializing JSON: \(error)")
                if let rawString = String(data: data, encoding: .utf8) {
                    print("Raw server response:\n\(rawString)")
                }
            }
        }
        
        task.resume()
        semaphore.wait()
        
        return result
    }

}
