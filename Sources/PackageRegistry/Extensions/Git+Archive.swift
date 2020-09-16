import Git
import Foundation

extension Git {
    public static let archive: Registry.Archiver = { release in
        let fileManager = FileManager()
        let tmp = temporaryURL()
        defer { try? fileManager.removeItem(at: tmp) }

        let repository = try Repository.clone(from: release.package.url, to: tmp)

        let tagNames = try repository.tagNames(matching: "*\(release.version)")
        guard let reference = tagNames.first(where: { $0 == "\(release.version)" ||
                                                      $0 == "v\(release.version)"})
        else {
            fatalError("unknown tag: [v]\(release.version)")
        }

        fileManager.changeCurrentDirectoryPath(tmp.path)

        let fileName = "\(UUID()).zip"
        try shell(Git.tool, with: ["archive",
                                   "--format", "zip",
                                   "--output", fileName,
                                   reference])

        return try Data(contentsOf: tmp.appendingPathComponent(fileName))
    }
}

