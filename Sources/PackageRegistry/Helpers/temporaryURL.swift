import Foundation

func temporaryURL() -> URL {
    let globallyUniqueString = ProcessInfo.processInfo.globallyUniqueString
    let path = "\(NSTemporaryDirectory())\(globallyUniqueString)"
    return URL(fileURLWithPath: path)
}
