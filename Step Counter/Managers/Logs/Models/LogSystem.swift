//
//  LogSystem.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/11/2025.
//

import Foundation
import OSLog

actor LogSystem {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ConsoleLogger")

    func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message)")
    }

    nonisolated func log(level: LogType, message: String) {
        Task {
            await log(level: level.OSLogType, message: message)
        }
    }
}
