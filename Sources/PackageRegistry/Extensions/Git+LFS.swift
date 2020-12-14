import Git
import Foundation
#if canImport(CryptoKit)
import CryptoKit
#else
import CryptoSwift
#endif

extension Git {
    public enum LargeFileStorage {
        public static let tool = try! which("git-lfs").path

        public struct File {
            public let path: String
            public let size: Int
            public let checksum: String

            init(path: String, size: Int, checksum: String) {
                self.path = path
                self.size = size
                self.checksum = checksum
            }

            init?(path: String, blob: Blob) {
                guard let content = String(data: blob.data, encoding: .utf8) else { return nil }
                let lines = content.split(separator: "\n")
                guard lines.count == 3,
                      lines[0] == "version https://git-lfs.github.com/spec/v1"
                else { return nil }

                self.path = path

                do {
                    let components = lines[2].split(separator: " ")
                    guard components.count == 2,
                          components.first == "size",
                          let numberOfBytes = Int(components.last!)
                    else { return nil }

                    self.size = numberOfBytes
                }

                do {
                    let components = lines[1].split(separator: ":")
                    guard components.count == 2,
                          components.first == "oid sha256"
                    else { return nil }

                    self.checksum = String(components.last!)
                }
            }
        }
    }
    
    public typealias LFS = LargeFileStorage
}

extension Repository.Index.Entry {
    public var externalFile: Git.LFS.File? {
        if let blob = blob {
            return Git.LFS.File(path: path, blob: blob)
        } else if !isConflict, let checksum = InputStream(fileAtPath: path)?.sha256Checksum {
            return Git.LFS.File(path: path, size: fileSize, checksum: checksum)
        } else {
            return nil
        }
    }
}

fileprivate extension InputStream {
    #if canImport(CryptoKit)
    var sha256Checksum: String {
        open()
        defer { close() }

        let bufferSize = 4096
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)

        var hasher = SHA256()
        accumulator: while hasBytesAvailable {
            let bytesRead = read(buffer, maxLength: bufferSize)
            guard bytesRead > 0 else { break accumulator }
            let bufferPointer = UnsafeRawBufferPointer(start: buffer, count: bytesRead)
            hasher.update(bufferPointer: bufferPointer)
        }
        let digest = hasher.finalize()
        return digest.hexadecimalRepresentation
    }
    #else
    var sha256Checksum: String {
        return Data(reading: self).sha256().hexadecimalRepresentation
    }
    #endif
}

fileprivate extension Data {
    init(reading input: InputStream) {
        self.init()

        input.open()
        defer { input.close() }

        let bufferSize = 4096
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)

        accumulator: while input.hasBytesAvailable {
            let bytesRead = input.read(buffer, maxLength: bufferSize)
            guard bytesRead > 0 else { break accumulator }
            append(buffer, count: bytesRead)
        }
        buffer.deallocate()
    }
}

fileprivate extension Sequence where Element == UInt8 {
    var hexadecimalRepresentation: String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}
