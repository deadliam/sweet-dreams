//
//  Utils.swift
//  Sweet Dreams
//
//  Created by Anatolii Kasianov on 26.08.2022.
//

import Foundation

class Utils {
    
    static func runScriptFromBundle(scriptName: String, args: [String] = [""]) -> Bool {
        let path = scriptPath(scriptName)
        var arguments = [path]
        arguments.append(contentsOf: args)
        
        let (output, exitCode) = Utils.executeShellCommand(cmd: "/bin/zsh", arguments: arguments)
        print(output)
        if output.contains("Operation not permitted") || exitCode != 0 || output.contains("Error") {
            return false
        }
        return true
    }
    
    static func scriptPath(_ scriptName: String) -> String {
        let path = Bundle(for: Utils.self)
            .path(forResource: (scriptName as NSString).deletingPathExtension, ofType: (scriptName as NSString).pathExtension)!
        return path
    }
    
    @discardableResult
    static func executeShellCommand(cmd: String, arguments: [String] = []) -> (output: String, exitCode: Int32) {
        // Create a Task instance
        let task = Process()
        var args: [String] = []
        args.append(contentsOf: arguments)
        // Set the task parameters
        task.launchPath = cmd
        
        task.arguments = args
        task.environment = [
            "LC_ALL": "en_US.UTF-8",
            "HOME": NSHomeDirectory()
        ]

        // Create a Pipe and make the task put all the output there
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        // Launch the task
        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

        return (output, task.terminationStatus)
    }
}
