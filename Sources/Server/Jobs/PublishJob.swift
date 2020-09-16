import Vapor
import PackageRegistry
import Foundation
import Queues
//
//struct PublishJob: Job {
//    typealias Payload = Release
//
//    func dequeue(_ context: QueueContext, _ payload: Payload) -> EventLoopFuture<Void> {
//        _ = try? registry.publish(version: payload.version, of: payload.package)
//        return context.eventLoop.future()
//    }
//
////    func error(_ context: QueueContext, _ error: Error, _ payload: Email) -> EventLoopFuture<Void> {
////        // If you don't want to handle errors you can simply return a future. You can also omit this function entirely.
////        return context.eventLoop.future()
////    }
//}
