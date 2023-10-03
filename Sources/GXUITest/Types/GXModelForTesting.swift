//
//  GXModelForTesting.swift
//  
//
//  Created by José Echagüe on 10/3/23.
//

import GXObjectsModel

internal class GXModelForTesting : GXModelObject {
	static var shared = GXModelForTesting()
	
	private init() {  }
	
	// MARK: - GXModelObject
	
	var gxModel: GXModel? { return nil }
}
