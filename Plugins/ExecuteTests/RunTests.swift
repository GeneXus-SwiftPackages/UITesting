//
//  RunTests.swift
//
//
//  Created by José Echagüe on 8/11/23.
//

import Foundation
import PackagePlugin

private protocol ToolProvider {
	func tool(named name: String) throws -> PackagePlugin.PluginContext.Tool
}

extension PluginContext: ToolProvider {  }

@main
struct RunTests {
	private func runTestsTool(from toolProvider: ToolProvider) throws -> PackagePlugin.PluginContext.Tool {
		try toolProvider.tool(named: "RunTests")
	}
	
	private func extrctResultsTool(from toolProvider: ToolProvider) throws -> PackagePlugin.PluginContext.Tool {
		try toolProvider.tool(named: "ExtractTestResults")
	}
	
	/// Expected arguments:
	///  - Required:
	///  -- projectPath (non-relative)
	///  -- schemeName
	///  -- testDestination (must double-quoted in order to be parsed correctly by the swift package command)
	///  - Optional:
	///  -- --swift-packages-path
	///  -- --xcode-override
	///  -- Rest of arguments are the names of tests to execute
	private func runAndExtractTests(using context: ToolProvider, arguments: [String], extractionPath: String) throws {
		guard arguments.count >= 3 else { throw Error.invalidNumberOfArguments }
		
		var projectPath = arguments[0]
		if !projectPath.hasSuffix(".xcodeproj") {
			projectPath.append(".xcodeproj")
		}
		
		let schemeName = arguments[1]
		let testDestination = arguments[2]

		var testExecutionArguments = [projectPath, schemeName, testDestination]
		
		if arguments.count >= 6 {
			testExecutionArguments.append(contentsOf: arguments[5...])
		}
		
		testExecutionArguments.append(contentsOf: ["--results-path", extractionPath])
		
		if arguments.count >= 4 {
			testExecutionArguments.append(contentsOf: ["--swift-packages-path", arguments[3]])
			
			if arguments.count >= 5 {
				testExecutionArguments.append(contentsOf: ["--xcode-override", arguments[4]])
			}
		}
		
		let runTestsTool = try self.runTestsTool(from: context)
		let xcResultsPath = try self.runProcess(with: runTestsTool.path.string, arguments: testExecutionArguments)
		
#if DEBUG
			print("Test results path: \(xcResultsPath)")
#endif
		
		let extractResultsTool = try self.extrctResultsTool(from: context)
		let extractTestsResults = try self.runProcess(with: extractResultsTool.path.string, arguments: [xcResultsPath, extractionPath ,"--extract-logs"])
		
		print(extractTestsResults)
	}
	
	private func runProcess(with launchPath: String, arguments: [String]) throws -> String {
#if DEBUG
		print("Launching process with launch path: \(launchPath)")
		print("Launch arguments: \(arguments)")
#endif
		var shellArguments = [launchPath]
		shellArguments.append(contentsOf: arguments)
		
		let process = Process()
		process.launchPath = launchPath
		process.arguments = arguments
		
		let outputPipe = Pipe()
		process.standardOutput = outputPipe
		let errorPipe = Pipe()
		process.standardError = errorPipe
		
		process.launch()
		process.waitUntilExit()
		
		guard process.terminationStatus == 0 else {
			let stdError = String(decoding: errorPipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
			
			throw Error.runtimeError(stdError, process.terminationStatus)
		}
		
		return String(decoding: outputPipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
	}
}


extension RunTests: CommandPlugin {
	func performCommand(context: PluginContext, arguments: [String]) async throws {
		guard let extractionPath = arguments.last else { throw Error.invalidNumberOfArguments }
		
		try self.runAndExtractTests(using: context, arguments: Array(arguments[0..<(arguments.count-1)]), extractionPath: extractionPath)
	}
}


#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension XcodePluginContext: ToolProvider {  }

extension RunTests: XcodeCommandPlugin {
	func performCommand(context: XcodePluginContext, arguments: [String]) throws {
		guard arguments.count >= 3 else { throw Error.invalidNumberOfArguments }
		
		let targetName = arguments[1]
		let testDestination = arguments[2]
		let buildProductDirPath = context.xcodeProject.directory.appending(["build"]).string
		let testProductDirPath = context.xcodeProject.directory.appending(["test"]).string
		
		let pluginArguments = [context.xcodeProject.directory.appending([context.xcodeProject.displayName]).string,
							   targetName,
							   testDestination,
							   buildProductDirPath]
		
		try self.runAndExtractTests(using: context, arguments: pluginArguments, extractionPath: testProductDirPath)
	}
}
#endif // canImport(XcodeProjectPlugin)

private enum Error: Swift.Error, LocalizedError {
	case runtimeError(String, Int32)
	case invalidNumberOfArguments
}
