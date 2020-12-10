import Git
import Foundation
import ZIPFoundation
import AnyCodable

public final class Registry {
    public typealias Archiver = (Release) throws -> Data

    let repository: Repository

    public let indexURL: URL

    public var archiver: Archiver = Git.archive

    init(repository: Repository) throws {
        guard let indexURL = repository.workingDirectory else {
            throw Error.invalidURL
        }

        self.repository = repository
        self.indexURL = indexURL
    }

    @discardableResult
    public class func create(at url: URL, with configuration: [String: String] = [:]) throws -> Registry {
        let fileManager = FileManager()
        try fileManager.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: [:])
        fileManager.changeCurrentDirectoryPath(url.path)

        let repository = try Repository.create(at: url)

        try shell(Git.LFS.tool, with: ["install"])

        for (name, value) in configuration {
            try shell(Git.tool, with: ["config", "add", name, value])
        }

        let attributes = #"""
        *.zip filter=lfs diff=lfs merge=lfs -text

        """#
        try attributes.data(using: .utf8)?.write(to: url.appendingPathComponent(".gitattributes"))

        // FIXME
//        try repository.index?.add(path: ".gitattributes")
//        try repository.createCommit(message: "Initialize registry", author: configuration.signature)
//        try repository.index?.reload(force: true)

        try shell(Git.tool, with: ["add", ".gitattributes"])
        try shell(Git.tool, with: ["commit",
                                   "-m", "Initialize registry"])

        return try Registry(repository: repository)
    }

    public class func open(at url: URL) throws -> Registry {
        guard url.isFileURL else { throw Error.invalidURL }

        let repository = try Repository.open(at: url)

        return try Registry(repository: repository)
    }

    public func packages() throws -> [Package] {
        try Set(repository.tagNames().compactMap { Package(tagName: $0) }).sorted()
    }

    public func releases() throws -> [Release] {
        try repository.tagNames().compactMap { Release(tagName: $0) }.sorted()
    }

    public func releases(for package: Package) throws -> [Release] {
        let tagNames = try repository.tagNames(matching: "\(package)/*".lowercased())
        return tagNames.compactMap { Release(tagName: $0) }.sorted()
    }

    public func metadata(for release: Release) throws -> [String: AnyCodable]? {
        guard let commit = repository[release.tagName]?.target as? Commit,
              let data = commit.note?.message.data(using: .utf8)
        else { return nil }

        return try JSONDecoder().decode([String: AnyCodable].self, from: data)
    }

    public func update(metadata: [String: AnyCodable], for release: Release) throws {
        guard let commit = repository[release.tagName]?.target as? Commit,
              let data = try? JSONEncoder().encode(metadata),
              let message = String(data: data, encoding: .utf8)
        else { return }

        try commit.addNote(message)
    }

    public func manifest(for release: Release, swiftVersion: String? = nil, completion: (Result<String, Swift.Error>) -> Void) {
        let url = URL(fileURLWithPath: release.archivePath, relativeTo: repository.workingDirectory)

        do {
            guard let archive = Archive(url: url, accessMode: .read) else { throw Error.archiveNotFound }

            let fileName: String
            if let swiftVersion = swiftVersion {
                fileName = "Package@swift-\(swiftVersion).swift"
            } else {
                fileName = "Package.swift"
            }

            guard Package.isValidManifestFile(fileName),
                  let entry = archive[fileName]
            else { throw Error.invalidManifest }

            _ = try archive.extract(entry, consumer: { (data) in
                guard let manifest = String(data: data, encoding: .utf8),
                      !manifest.isEmpty
                else { throw Error.invalidManifest }
                completion(.success(manifest))
            })
        } catch {
            completion(.failure(error))
        }
    }

    @discardableResult
    public func publish(version: Version, of package: Package) throws -> Release {
        let release = Release(package: package, version: version)

        let fileManager = FileManager()
        let destination = URL(fileURLWithPath: release.archivePath, relativeTo: repository.workingDirectory)

        if fileManager.fileExists(atPath: destination.path) {
            throw Error.releaseAlreadyExists
        }

        try fileManager.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [:])
        try archiver(release).write(to: destination)

        // FIXME: Add file through Git to apply LFS filter; not sure how to do this with libgit2 wrapper...
//        try repository.index?.add(path: route(for: package) + "/" + fileName, force: true)
//        let commit = try repository.createCommit(message: "Publish \(package.owner)/\(package.name) \(version)", author: Registry.signature, committer: Registry.signature)
//        try repository.createLightweightTag(named: tagName(for: release), target: commit)

        fileManager.changeCurrentDirectoryPath(repository.workingDirectory!.path)

        try shell(Git.tool, with: ["add", destination.relativePath])
        try shell(Git.tool, with: ["commit",
                                   "--message", "Publish \(package) \(version)"])
        try shell(Git.tool, with: ["tag", release.tagName])
        try repository.index?.reload(force: true)

        return release
    }

    public func archive(of release: Release) -> Git.LFS.File? {
        repository.index?[release.archivePath]?.externalFile
    }
}
