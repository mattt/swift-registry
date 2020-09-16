import PackageRegistry
import ArgumentParser

// TODO: ExpressibleByArgument ---> automatic if losslessstringconvertible?

extension Version: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(argument)
    }
}

extension Package: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(argument)
    }
}
