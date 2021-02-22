import Git
import Foundation

extension Git {
    public static let archive: Registry.Archiver = { release in
        let fileManager = FileManager()
        let tmp = try temporaryDirectory().appendingPathComponent("\(release.package.name)-\(release.version)")
        defer { try? fileManager.removeItem(at: tmp) }

        let owner = release.package.scope.dropFirst()
        let project = release.package.name
        guard let url = URL(string: "https://github.com/\(owner)/\(project)") else {
            throw Error("invalid url for package: \(release)")
        }

        let repository = try Repository.clone(from: url, to: tmp)

        let tagNames = try repository.tagNames(matching: "*\(release.version)")
        guard let reference = tagNames.first(where: { $0 == "\(release.version)" ||
                                                      $0 == "v\(release.version)"})
        else {
            throw Error("unknown tag: [v]\(release.version)")
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

