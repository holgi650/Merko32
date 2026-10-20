//
//  ManualTicker.swift
//  Merko32Tests
//

@testable import Merko32

/// Ticker für Tests: tickt nur, wenn `fire()` aufgerufen wird.
@MainActor
final class ManualTicker: Ticker {
    private var onTick: (@MainActor () -> Void)?
    private(set) var startCount = 0
    private(set) var stopCount = 0

    var isRunning: Bool { onTick != nil }

    func start(_ onTick: @escaping @MainActor () -> Void) {
        startCount += 1
        self.onTick = onTick
    }

    func stop() {
        stopCount += 1
        onTick = nil
    }

    func fire(times: Int = 1) {
        for _ in 0..<times {
            onTick?()
        }
    }
}
