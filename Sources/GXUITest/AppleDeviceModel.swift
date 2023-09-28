//
//  AppleDeviceModel.swift
//  
//
//  Created by José Echagüe on 8/14/23.
//

import Foundation

internal enum AppleDeviceModel : String {
#if os(iOS)
	case iPodTouch6thGeneration = "iPod touch (6th generation)"
	case iPodTouch7thGeneration = "iPod touch (7th generation)"
	
	case iPhone5S = "iPhone 5s"
	case iPhone6	 = "iPhone 6"
	case iPhone6Plus = "iPhone 6 Plus"
	case iPhone6S 		= "iPhone 6s"
	case iPhone6SPlus 	= "iPhone 6s Plus"
	case iPhoneSE1stGeneration = "iPhone SE"
	case iPhone7 		= "iPhone 7"
	case iPhone7Plus 	= "iPhone 7 Plus"
	case iPhone8 		= "iPhone 8"
	case iPhone8Plus 	= "iPhone 8 Plus"
	case iPhoneX		= "iPhone X"
	case iPhoneXS		= "iPhone XS"
	case iPhoneXSMax	= "iPhone XS Max"
	case iPhoneXR		= "iPhone XR"
	case iPhone11		= "iPhone 11"
	case iPhone11Pro	= "iPhone 11 Pro"
	case iPhone11ProMax	= "iPhone 11 Pro Max"
	case iPhoneSE2ndGeneration = "iPhone SE (2nd generation)"
	case iPhone12Mini	= "iPhone 12 mini"
	case iPhone12		= "iPhone 12"
	case iPhone12Pro	= "iPhone 12 Pro"
	case iPhone12ProMax	= "iPhone 12 Pro Max"
	case iPhone13Mini	= "iPhone 13 mini"
	case iPhone13		= "iPhone 13"
	case iPhone13Pro	= "iPhone 13 Pro"
	case iPhone13ProMax	= "iPhone 13 Pro Max"
	case iPhoneSE3rdGeneration = "iPhone SE (3rd generation)"
	case iPhone14		= "iPhone 14"
	case iPhone14Plus	= "iPhone 14 Plus"
	case iPhone14Pro	= "iPhone 14 Pro"
	case iPhone14ProMax	= "iPhone 14 Pro Max"
	case iPhone15		= "iPhone 15"
	case iPhone15Plus	= "iPhone 15 Plus"
	case iPhone15Pro	= "iPhone 15 Pro"
	case iPhone15ProMax	= "iPhone 15 Pro Max"
	case iPad5thGeneration = "iPad (5th generation)"
	case iPad6thGeneration = "iPad (6th generation)"
	case iPad7thGeneration = "iPad (7th generation)"
	case iPad8thGeneration = "iPad (8th generation)"
	case iPad9thGeneration = "iPad (9th generation)"
	case iPad10thGeneration = "iPad (10th generation)"
	case iPadAir	= "iPad Air"
	case iPadAir2 	= "iPad Air 2"
	case iPadAir3rdGeneration = "iPad Air (3rd generation)"
	case iPadAir4thGeneration = "iPad Air (4th generation)"
	case iPadAir5thGeneration = "iPad Air (5th generation)"
	case iPadMini2 = "iPad mini 2"
	case iPadMini3 = "iPad mini 3"
	case iPadMini4 = "iPad mini 4"
	case iPadMini5thGeneration = "iPad mini (5th generation)"
	case iPadMini6thGeneration = "iPad mini (6th generation)"
	case iPadPro9_7	 = "iPad Pro (9.7-inch)"
	case iPadPro10_5 = "iPad Pro (10.5-inch)"
	case iPadPro111stGeneration = "iPad Pro (11-inch) (1st generation)"
	case iPadPro112ndGeneration = "iPad Pro (11-inch) (2nd generation)"
	case iPadPro113rdGeneration = "iPad Pro (11-inch) (3rd generation)"
	case iPadPro114thGeneration = "iPad Pro (11-inch) (4th generation)"
	case iPadPro12_91stGeneration = "iPad Pro (12.9-inch) (1st generation)"
	case iPadPro12_92ndGeneration = "iPad Pro (12.9-inch) (2nd generation)"
	case iPadPro12_93rdGeneration = "iPad Pro (12.9-inch) (3rd generation)"
	case iPadPro12_94thGeneration = "iPad Pro (12.9-inch) (4th generation)"
	case iPadPro12_95thGeneration = "iPad Pro (12.9-inch) (5th generation)"
	case iPadPro12_96thGeneration = "iPad Pro (12.9-inch) (6th generation)"
#elseif os(tvOS)
	case AppleTV 	= "Apple TV"
	case AppleTV4K 	= "Apple TV 4K"
#elseif os(watchOS)
	// ...
#endif
	
	static let current: AppleDeviceModel = {
		var systemInfo = utsname()
		uname(&systemInfo)
		let machineMirror = Mirror(reflecting: systemInfo.machine)
		
		var identifier = machineMirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8, value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}
		
		func mapToModelName(identifier: String) -> String {
#if os(iOS)
			switch identifier {
			case "iPod7,1":                                       return "iPod touch (6th generation)"
			case "iPod9,1":                                       return "iPod touch (7th generation)"
			case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
			case "iPhone7,2":                                     return "iPhone 6"
			case "iPhone7,1":                                     return "iPhone 6 Plus"
			case "iPhone8,1":                                     return "iPhone 6s"
			case "iPhone8,2":                                     return "iPhone 6s Plus"
			case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
			case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
			case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
			case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
			case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
			case "iPhone11,2":                                    return "iPhone XS"
			case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
			case "iPhone11,8":                                    return "iPhone XR"
			case "iPhone12,1":                                    return "iPhone 11"
			case "iPhone12,3":                                    return "iPhone 11 Pro"
			case "iPhone12,5":                                    return "iPhone 11 Pro Max"
			case "iPhone13,1":                                    return "iPhone 12 mini"
			case "iPhone13,2":                                    return "iPhone 12"
			case "iPhone13,3":                                    return "iPhone 12 Pro"
			case "iPhone13,4":                                    return "iPhone 12 Pro Max"
			case "iPhone14,4":                                    return "iPhone 13 mini"
			case "iPhone14,5":                                    return "iPhone 13"
			case "iPhone14,2":                                    return "iPhone 13 Pro"
			case "iPhone14,3":                                    return "iPhone 13 Pro Max"
			case "iPhone14,7":                                    return "iPhone 14"
			case "iPhone14,8":                                    return "iPhone 14 Plus"
			case "iPhone15,2":                                    return "iPhone 14 Pro"
			case "iPhone15,3":                                    return "iPhone 14 Pro Max"
			case "iPhone15,4":                                    return "iPhone 15"
			case "iPhone15,5":                                    return "iPhone 15 Plus"
			case "iPhone16,1":                                    return "iPhone 15 Pro"
			case "iPhone16,2":                                    return "iPhone 15 Pro Max"
			case "iPhone8,4":                                     return "iPhone SE"
			case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
			case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
			case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
			case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
			case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
			case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
			case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
			case "iPad13,18", "iPad13,19":                        return "iPad (10th generation)"
			case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
			case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
			case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
			case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
			case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
			case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
			case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
			case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
			case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
			case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
			case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
			case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
			case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
			case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
			case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
			case "iPad14,3", "iPad14,4":                          return "iPad Pro (11-inch) (4th generation)"
			case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
			case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
			case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
			case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
			case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
			case "iPad14,5", "iPad14,6":                          return "iPad Pro (12.9-inch) (6th generation)"
			case "i386", "x86_64", "arm64":                       return mapToModelName(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!)
			default:                                              return identifier
			}
#endif // os(iOS)
		}
		identifier = mapToModelName(identifier: identifier)
		guard let currentDeviceModel = AppleDeviceModel.init(rawValue: identifier) else {
			fatalError("Unable to determine current device model from identifier: \(identifier)")
		}
		return currentDeviceModel
	}()
	
	private enum SafeAreaInsetsCategory {
		case originaliPhoneDesign
		case iPhoneXLike
		case iPhone11Like
		case iPhone12Like
		case iPhone12MiniLike
		case iPhone14ProLike
		case originaliPadDesign
		case iPadWithoutTouchID
		
		func safeAreaInsets(for orientation: UIDeviceOrientation) -> UIEdgeInsets {
			#if DEBUG
				guard orientation.isValidInterfaceOrientation else { fatalError("Unknown orientation not supported") }
			#endif
			
			switch self {
			case .originaliPhoneDesign, .originaliPadDesign:
				return .init(top: 20, left: 0, bottom: 0, right: 0)
			case .iPhoneXLike:
				return orientation.isPortrait ? .init(top: 44, left: 0, bottom: 34, right: 0) : .init(top: 0, left: 44, bottom: 21, right: 44)
			case .iPhone11Like:
				return orientation.isPortrait ? .init(top: 48, left: 0, bottom: 34, right: 0) : .init(top: 0, left: 48, bottom: 21, right: 48)
			case .iPhone12Like:
				return orientation.isPortrait ? .init(top: 47, left: 0, bottom: 34, right: 0) : .init(top: 0, left: 47, bottom: 21, right: 47)
			case .iPhone12MiniLike:
				return orientation.isPortrait ? .init(top: 50, left: 0, bottom: 34, right: 0) : .init(top: 0, left: 50, bottom: 21, right: 50)
			case .iPhone14ProLike:
				return orientation.isPortrait ? .init(top: 59, left: 0, bottom: 34, right: 0) : .init(top: 0, left: 59, bottom: 21, right: 59)
			case .iPadWithoutTouchID:
				return .init(top: 24, left: 0, bottom: 0, right: 0)
			}
		}
	}
	
	private var safeAreaInsetsCategory: SafeAreaInsetsCategory {
		switch self {
		case .iPodTouch6thGeneration, .iPodTouch7thGeneration, .iPhone5S, .iPhone6, .iPhone6Plus, .iPhone6S, .iPhone6SPlus, .iPhoneSE1stGeneration, .iPhone7, .iPhone7Plus, .iPhone8, .iPhone8Plus, .iPhoneSE2ndGeneration, .iPhoneSE3rdGeneration:
			return .originaliPhoneDesign
		case .iPhoneX, .iPhoneXS, .iPhoneXSMax, .iPhone11Pro, .iPhone11ProMax:
			return .iPhoneXLike
		case .iPhoneXR, .iPhone11:
			return .iPhone11Like
		case .iPhone12, .iPhone12Pro, .iPhone12ProMax, .iPhone13, .iPhone13Pro, .iPhone13ProMax, .iPhone14, .iPhone14Plus, .iPhone15, .iPhone15Plus:
			return .iPhone12Like
		case .iPhone12Mini, .iPhone13Mini:
			return .iPhone12MiniLike
		case .iPhone14Pro, .iPhone14ProMax, .iPhone15Pro, .iPhone15ProMax:
			return .iPhone14ProLike
		case .iPad5thGeneration, .iPad6thGeneration, .iPad7thGeneration, .iPad8thGeneration, .iPad9thGeneration, .iPadAir, .iPadAir2, .iPadAir3rdGeneration, .iPadAir4thGeneration, .iPadAir5thGeneration, .iPadMini2, .iPadMini3, .iPadMini4, .iPadMini5thGeneration, .iPadPro9_7, .iPadPro10_5, .iPadPro12_91stGeneration, .iPadPro12_92ndGeneration:
			return .originaliPadDesign
		case .iPad10thGeneration, .iPadMini6thGeneration, .iPadPro111stGeneration, .iPadPro112ndGeneration, .iPadPro113rdGeneration, .iPadPro114thGeneration, .iPadPro12_93rdGeneration, .iPadPro12_94thGeneration, .iPadPro12_95thGeneration, .iPadPro12_96thGeneration:
			return .iPadWithoutTouchID
		}
	}
	
	func safeAreaInsets(for orientation: UIDeviceOrientation) -> UIEdgeInsets {
		self.safeAreaInsetsCategory.safeAreaInsets(for: orientation)
	}
}
