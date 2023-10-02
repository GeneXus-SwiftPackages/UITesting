//
//  GXTestsExecutionEnvironment.swift
//
//
//  Created by José Echagüe on 10/2/23.
//

import CoreData

import GXObjectsModel

class GXTestsExecutionEnvironment : NSObject {
	static var setTestExecutionEnvironmentOnce: Void = {
		//let helperInternal = unsafeBitCast(GXExecutionEnvironmentHelper.self, to: GXExecutionEnvironmentHelper_GXInternal.Type.self)
		
		let testExecutionEnvironment = GXTestsExecutionEnvironment()
		
		GXExecutionEnvironmentHelper.perform(NSSelectorFromString("setCurrentExecutionEnvironment:"), with: testExecutionEnvironment)
	}()
	
	public class func setTestExecutionEnvironment() {
		_ = setTestExecutionEnvironmentOnce
	}
	
	public class func setTestExecutionEnvironmentAndGXModel() {
		setTestExecutionEnvironment()
		
		GXModel.perform(NSSelectorFromString("setCurrentModel:"), with: testGXModel())
	}
	
	public class func testGXModel(modelInfo: GXModelInfo? = nil, appModel: GXApplicationModel? = nil) -> GXModel? {
		let modelObjects = [ "GXCoreDataCacheManagedObjectModel": NSManagedObjectModel() ]
		return GXModel(modelInfo: modelInfo ?? GXModelInfo(), applicationModel: appModel ?? testAppModel() , modelObjects: modelObjects)
	}
	
	public class func testAppModel<GXAppModelType: GXApplicationModel>(resources: GXResources? = nil,
																	   appSettings: GXApplicationSettings? = nil,
																	   entryPoint: GXApplicationEntryPoint? = nil,
																	   objectModelsByType: [GXObjectType : [GXNamedElement & GXModelObject]]? = nil,
																	   appServerBaseUrl: URL = URL(string: "http://localhost")!,
																	   serverType: GXApplicationServerType = .dotNet) -> GXAppModelType {
		let mappedObjectModelsById: [String : [String : GXNamedElement & GXModelObject]]?
		mappedObjectModelsById = objectModelsByType?.mapValues { $0.dictionary { $0.name!.lowercased() } }.mapKeys { GXObjectHelper.objectTypeString(fromEnum: $0) ?? "" }
		let entryPoint = testApplicationEntryPoint(from: entryPoint, objectModelsByType: objectModelsByType)
		return GXAppModelType.init(appServerBaseUrl: appServerBaseUrl,
								   serverType: serverType,
								   appUUID: UUID().uuidString,
								   version: 1,
								   minorVersion: 0,
								   majorVersion: 1,
								   entryPoint: entryPoint,
								   objectModelsById: mappedObjectModelsById,
								   resources: resources ?? GXResources(modelObject: nil),
								   settings: appSettings ?? testAppSettings(),
								   for: nil)
	}
	
	public class func testApplicationEntryPoint(from entryPoint: GXApplicationEntryPoint? = nil, objectModelsByType: [GXObjectType : [GXNamedElement & GXModelObject]]? = nil, properties: [String: Any]? = nil) -> GXApplicationEntryPoint {
		if let entryPoint = entryPoint {
			return entryPoint
		}
		
		return GXApplicationEntryPoint_Menu(name: "main", properties: properties)
	}
	
	public class func testAppSettings(styleObjectName: String? = nil,
							   styleObjectType: GXObjectType? = nil,
							   convertTimesFromUTC: Bool? = nil) -> GXApplicationSettings {
		return GXApplicationSettings(version: nil,
									 styleObjectName: styleObjectName,
									 styleObjectType: styleObjectType ?? .unknown,
									 navigationStyle: nil,
									 convertTimesFromUTC: convertTimesFromUTC ?? false,
									 defaultInterfaceOrientation: .any,
									 defaultLabelPosition: .platformDefault,
									 imageUploadSizes: nil,
									 validPlatformNames: nil,
									 ideConnectionString: nil)
	}
}

extension GXTestsExecutionEnvironment : GXExecutionEnvironment {
	public var applicationState: GXApplicationStateType {
	 return .active
 }
 
 public var isTransitioningFromBackgroundToForeground: Bool {
	 return false
 }
 
 public var activeStateNotificationsSupported: Bool {
	 return false
 }
 
 public var didBecomeActiveNotification: String? {
	 return nil
 }
 
 public var willResignActiveNotification: String? {
	 return nil
 }
 
 public var didReceiveMemoryWarningNotification: String? {
	 return nil
 }
 
 public var willTerminateNotification: String? {
	 return nil
 }
 
 public var isMultitaskingSupported: Bool {
	 return false
 }
 
 public var multitaskingNotificationsSupported: Bool {
	 return false
 }
 
 public var didEnterBackgroundNotification: String? {
	 return nil
 }
 
 public var willEnterForegroundNotification: String? {
	 return nil
 }
 
 public var currentTraitCollection: UITraitCollection {
	 if #available(iOS 13.0, tvOS 13.0, *) {
		 return UITraitCollection.current
	 }
	 return ((keyWindow ?? UIScreen.main) as UITraitEnvironment).traitCollection
 }
 
 public var keyWindow: UIWindow? {
	 return nil
 }
 
 public var windows: [UIWindow] {
	 []
 }
 
 @available(iOS 13.0, tvOS 13.0, *)
 public var connectedScenes: Set<UIScene> {
	 return .init()
 }
 
 @available(iOS 13.0, tvOS 13.0, *)
 public var openSessions: Set<UISceneSession> {
	 return .init()
 }
 
 public func sendAction(toFirstResponder action: Selector) {
 }
 
 public var userInterfaceLayoutDirection: UIUserInterfaceLayoutDirection {
	 return .leftToRight
 }
 
 public var statusBarFrame: CGRect {
	 return .zero
 }
 
 public var interfaceOrientation: UIInterfaceOrientation {
	 return .portrait
 }
 
 public var supportedInterfaceOrientationsForKeyWindow: UIInterfaceOrientationMask {
	 return .all
 }
 
 public var preferredContentSizeCategory: UIContentSizeCategory {
	 return .medium
 }
 
 public var preferredContentSizeCategoryIsAccessibilityCategory: Bool {
	 return false
 }
}
