//
//  OSLogClient.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/11/2025.
//

import Foundation

struct OSLogClient: LogClient {
    let logger = LogSystem()
    private let printParameters: Bool

    init(printParameters: Bool = true) {
        self.printParameters = printParameters
    }

    func trackEvent(event: LoggableEvent) {
        var string = "\(event.type.emoji) \(event.eventName)"

        if printParameters, let parameters = event.parameters, !parameters.isEmpty {
            string += " with parameters:"
            let sortedKeys = Array(parameters.keys).sorted()
            for key in sortedKeys {
                if let value = parameters[key] {
                    string += "\n    \(key): \(value)"
                }
            }
        }

        logger.log(level: event.type, message: string)
    }

    func trackScreenEvent(event: LoggableEvent) {
        trackEvent(event: event)
    }
}
