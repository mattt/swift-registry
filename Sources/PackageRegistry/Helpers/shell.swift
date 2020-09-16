import Foundation

@discardableResult
func shell(_ command: String, with arguments: [String] = []) throws -> Data {
    let task = Process()
    let url = URL(fileURLWithPath: command)
    if #available(OSX 10.13, *) {
        task.executableURL = url
    } else {
        task.launchPath = url.path
    }

    var environment =  ProcessInfo.processInfo.environment
    if let path = environment["PATH"] {
        environment["PATH"] = "/usr/local/bin" + ":\(path)"
    } else {
        environment["PATH"] = "/usr/local/bin"
    }
    task.environment = environment

    task.arguments = arguments

    let pipe = Pipe()
    task.standardOutput = pipe
    if #available(OSX 10.13, *) {
        try task.run()
    } else {
        task.launch()
    }

    task.waitUntilExit()

    return pipe.fileHandleForReading.readDataToEndOfFile()
}
