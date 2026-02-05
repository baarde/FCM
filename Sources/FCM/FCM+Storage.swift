//
//  FCM+Storage.swift
//
//
//  Created by Alessandro Di Maio on 07/09/23.
//

import Foundation
import NIOConcurrencyHelpers
import Vapor

extension FCM {
    public struct Storage {
        private let application: Application

        private var container: Container {
            application.locks.lock(for: ContainerKey.self).withLock {
                if let existing = application.storage[ContainerKey.self] {
                    return existing
                }
                let new = Container([:])
                application.storage.set(ContainerKey.self, to: new)
                return new
            }
        }

        init(application: Application) {
            self.application = application
        }

        public func client(_ id: FCM.ID) -> FCM {
            container.withLockedValue { clients in
                guard let client = clients[id] else {
                    fatalError("No clients configured for \(id)")
                }
                return client
            }
        }

        public func use(_ id: FCM.ID, configuration: FCMConfiguration) {
            container.withLockedValue { clients in
                guard !clients.keys.contains(id) else {
                    fatalError("Cannot change fcm client config of \(id) while running.")
                }
                clients[id] = FCM(client: application.client, configuration: configuration)
            }
        }
    }
}

extension FCM.Storage {
    private typealias Container = NIOLockedValueBox<[FCM.ID: FCM]>

    private struct ContainerKey: StorageKey, LockKey {
        typealias Value = Container
    }
}
