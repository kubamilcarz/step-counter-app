//
//  MockLogClient.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/11/2025.
//

import Foundation

final class MockLogClient: LogClient {
    private(set) var trackEventCallCount = 0
    private(set) var trackScreenEventCallCount = 0

    private(set) var recordedEvents: [any LoggableEvent] = []
    private(set) var recordedScreenEvents: [any LoggableEvent] = []

    var didTrackEvent: ((any LoggableEvent) -> Void)?

    var didTrackScreenEvent: ((any LoggableEvent) -> Void)?

    private let shouldRecordEvents: Bool

    init(
        shouldRecordEvents: Bool = true,
        didTrackEvent: ((any LoggableEvent) -> Void)? = nil,
        didTrackScreenEvent: ((any LoggableEvent) -> Void)? = nil
    ) {
        self.shouldRecordEvents = shouldRecordEvents
        self.didTrackEvent = didTrackEvent
        self.didTrackScreenEvent = didTrackScreenEvent
    }

    func trackEvent(event: LoggableEvent) {
        trackEventCallCount += 1

        if shouldRecordEvents {
            recordedEvents.append(event)
        }

        didTrackEvent?(event)
    }

    func trackScreenEvent(event: LoggableEvent) {
        trackScreenEventCallCount += 1

        if shouldRecordEvents {
            recordedScreenEvents.append(event)
        }

        didTrackScreenEvent?(event)
    }

    var lastRecordedEvent: (any LoggableEvent)? {
        recordedScreenEvents.last ?? recordedEvents.last
    }

    func reset() {
        trackEventCallCount = 0
        trackScreenEventCallCount = 0
        recordedEvents.removeAll()
        recordedScreenEvents.removeAll()
    }
}
