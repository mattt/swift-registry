public enum Git {
    public static let tool = try! which("git").path

    struct Error: Swift.Error, LosslessStringConvertible, CustomStringConvertible {
        var description: String

        init(_ description: String) {
            self.description = description
        }
    }
}
