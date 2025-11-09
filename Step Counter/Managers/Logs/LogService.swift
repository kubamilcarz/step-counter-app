//
//  LogService.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/11/2025.
//

import Foundation

@Observable
final class LogService {
    private let clients: [LogClient]

    init(clients: [LogClient] = []) {
        self.clients = clients
    }

    func trackEvent(event: AnyLoggableEvent) {
        for client in clients {
            client.trackEvent(event: event)
        }
    }

    func trackEvent(event: LoggableEvent) {
        for client in clients {
            client.trackEvent(event: event)
        }
    }

    func trackEvent(eventName: String, parameters: [String: Any]? = nil, type: LogType = .analytic) {
        let event = AnyLoggableEvent(eventName: eventName, parameters: parameters, type: type)

        for client in clients {
            client.trackEvent(event: event)
        }
    }
}
