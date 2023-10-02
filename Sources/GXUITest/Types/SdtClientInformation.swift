//
//  SdtClientInformation.swift
//  
//
//  Created by José Echagüe on 10/1/23.
//

final public class genexus_client_SdtClientInformation : GXStandardClasses.GXUserType {
	public lazy var gxTv_SdtClientInformation_Id: String = GXClientInformation.deviceUUID(for: self) ?? ""

	public lazy var gxTv_SdtClientInformation_Osname: String = GXClientInformation.osName()

	public lazy var gxTv_SdtClientInformation_Osversion: String = GXClientInformation.osVersion()

	public lazy var gxTv_SdtClientInformation_Language: String = GXClientInformation.deviceLanguage()

	public lazy var gxTv_SdtClientInformation_Devicetype: Int = Int(GXClientInformation.deviceType())

	public lazy var gxTv_SdtClientInformation_Platformname: String = GXClientInformation.platformName(for: self)

	public lazy var gxTv_SdtClientInformation_Appversioncode: String = GXClientInformation.appVersionCode(for: self)

	public lazy var gxTv_SdtClientInformation_Appversionname: String = GXClientInformation.appVersionName(for: self)

	public lazy var gxTv_SdtClientInformation_Applicationid: String = GXClientInformation.appIdentifier(for: self)
}
