import Logging
import ArgumentParser

extension Logger.Level: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(rawValue: argument)
    }
}
