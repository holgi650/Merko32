//
//  Ticker.swift
//  Merko32
//

import Foundation

/// Liefert einmal pro Sekunde einen Tick. In Tests wird ein manueller Ticker eingesetzt.
@MainActor
protocol Ticker: AnyObject {
    func start(_ onTick: @escaping @MainActor () -> Void)
    func stop()
}

/// Produktions-Ticker auf Basis einer echten Uhr.
@MainActor
final class ClockTicker<C: Clock>: Ticker where C.Duration == Duration {
    private let clock: C
    private var task: Task<Void, Never>?

    init(clock: C) {
        self.clock = clock
    }

    func start(_ onTick: @escaping @MainActor () -> Void) {
        stop()
        task = Task { [clock] in
            while !Task.isCancelled {
                do {
                    try await clock.sleep(for: .seconds(1))
                } catch {
                    return  // abgebrochen
                }
                onTick()
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }
}

extension ClockTicker where C == ContinuousClock {
    convenience init() {
        self.init(clock: ContinuousClock())
    }
}
