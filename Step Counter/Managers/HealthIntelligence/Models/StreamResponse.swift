//
//  StreamResponse.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import Foundation

@available(iOS 26.0, *)
struct StreamResponse: Sendable {
    let text: String

    init(text: String) {
        self.text = text
    }
}
