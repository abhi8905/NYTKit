//
//  NetworkMonitor.swift
//  NYTimes
//
//  Created by Abhinav Jha on 10/07/2025.
//

import Foundation
import Network
import Combine

@MainActor
public protocol NetworkMonitoring: AnyObject {
    var isConnected: Bool { get }
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }
}

@MainActor
public final class NetworkMonitor: NetworkMonitoring {

    public static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private let subject = CurrentValueSubject<Bool, Never>(false)

    public var isConnected: Bool {
        subject.value
    }

    public var isConnectedPublisher: AnyPublisher<Bool, Never> {
        subject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let newStatus = path.status == .satisfied

            Task { @MainActor in
                guard let self = self else { return }
                if self.subject.value != newStatus {
                    self.subject.send(newStatus)
                }
            }
        }

        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
