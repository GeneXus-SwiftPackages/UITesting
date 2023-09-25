//
//  HelperExtensions.swift
//  
//
//  Created by José Echagüe on 8/14/23.
//

import Foundation

internal extension UIEdgeInsets {
	func scaled(by scale: CGFloat) -> UIEdgeInsets {
		UIEdgeInsets.init(top: self.top * scale, left: self.left * scale, bottom: self.bottom * scale, right: self.right * scale)
	}
}

internal extension CGSize {
	func scaled(by scale: CGFloat) -> CGSize {
		CGSize.init(width: self.width * scale, height: self.height * scale)
	}
}
