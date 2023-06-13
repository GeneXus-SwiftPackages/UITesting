// swift-tools-version: 5.7
import PackageDescription

let package = Package(
	name: "GXUITest",
	platforms: [.iOS("12.0")],
	products: [
		.library(
			name: "GXUITest",
			targets: ["GXUITest"])
	],
	dependencies: [
		.package(url: "https://github.com/GeneXus-SwiftPackages/GXStandardClasses.git", .upToNextMajor(from: "1.0.0-beta.20230613192339"))
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
				   ],
					resources: [
						.copy("SampleImages.xcassets")
					]
		)
	]
)
