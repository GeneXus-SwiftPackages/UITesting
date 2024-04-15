// swift-tools-version: 5.9
import PackageDescription

let GX_FC_LAST_VERSION = Version("2.0.0-beta")

let package = Package(
	name: "GXUITest",
	platforms: [.iOS("12.0")],
	products: [
		.library(
			name: "GXUITest",
			targets: ["GXUITest"])
	],
	dependencies: [
		.package(url: "https://github.com/GeneXus-SwiftPackages/GXStandardClasses.git", .upToNextMajor(from: GX_FC_LAST_VERSION)),
		.package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.1.0")
	],
	targets: [
		.target(name: "GXUITest",
				dependencies: [
					.product(name: "GXStandardClasses", package: "GXStandardClasses"),
				]
		),

		.testTarget(name: "GXUITestUnitTests",
				   dependencies: [
					"GXUITest",
					.product(name: "OHHTTPStubsSwift", package: "ohhttpstubs")
				   ],
					resources: [
						.copy("SampleImages.xcassets")
					]
		)
	]
)
