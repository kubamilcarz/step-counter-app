//
//  LogClient.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/11/2025.
//

import Foundation

protocol LogClient {
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}
