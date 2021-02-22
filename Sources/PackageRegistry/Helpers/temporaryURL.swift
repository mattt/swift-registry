import Foundation
#if os(Linux)
import Glibc
#endif

func temporaryDirectory() throws -> URL {
    #if os(Linux)
    let env = ProcessInfo.processInfo.environment
    var prefix = env["TMPDIR"] ?? env["TEMP"] ?? env["TMP"] ?? "/tmp"
    if !prefix.hasSuffix("/") {
        prefix += "/"
    }
    let path = prefix + "\(ProcessInfo.processInfo.globallyUniqueString).XXXXXX"

    return try path.withCString { template in
        let pointer = UnsafeMutablePointer<Int8>(mutating: template)
        guard let cString = mkdtemp(pointer) else { throw CocoaError.error(.featureUnsupported) }
        let url = URL(fileURLWithPath: String(cString: cString), isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: [:])
        return url
    }
    #else
    let url: URL
    if #available(OSX 10.12, iOS 10, tvOS 10, watchOS 3, *) {
        url = FileManager.default.temporaryDirectory
    } else {
        url = URL(fileURLWithPath: NSTemporaryDirectory())
    }
    return try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: url, create: true)
    #endif
}
