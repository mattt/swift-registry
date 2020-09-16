import Foundation

func which(_ command: String) throws -> URL {
    let data = try shell("/usr/bin/which", with: [command])
    let string = String(data: data, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
    return URL(fileURLWithPath: string)
}
