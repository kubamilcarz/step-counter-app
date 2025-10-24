//
//  Step_Counter_Tests.swift
//  Step Counter Tests
//
//  Created by Kuba Milcarz on 24/10/2025.
//

import Testing
@testable import Step_Counter

struct Step_Counter_Tests {

    @Test func arrayAverages() async throws {
        let array: [Double] = [2.0, 3.1, 0.45, 1.84]
        #expect(array.average == 1.8475)
    }

}
