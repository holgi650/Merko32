//
//  RunGeneratorTests.swift
//  Merko32Tests
//

import Testing
@testable import Merko32

struct RunGeneratorTests {

    static let seeds: ClosedRange<UInt64> = 1...1000
    let config = GameConfig.standard

    private func makeRun(seed: UInt64) -> Run {
        var rng = SeededGenerator(seed: seed)
        return RunGenerator.make(config: config, using: &rng)
    }

    @Test func screensHaveCorrectDistribution() {
        for seed in Self.seeds {
            let run = makeRun(seed: seed)
            #expect(run.screens.count == 16)
            for (index, screen) in run.screens.enumerated() {
                #expect(screen.index == index)
                #expect(screen.seconds == config.secondsPerScreen[index])
                #expect(screen.fields.count == 4)
                #expect(screen.fields.filter { !$0.isQuery }.count == config.newPerScreen[index])
                #expect(screen.fields.filter(\.isQuery).count == config.queryPerScreen[index])
            }
        }
    }

    @Test func combinationsAndNumbersAreDistinct() {
        for seed in Self.seeds {
            let run = makeRun(seed: seed)
            #expect(run.items.count == 32)
            #expect(Set(run.items.map(\.combination)).count == 32)
            #expect(Set(run.items.map(\.number)).count == 32)
            #expect(run.items.allSatisfy { config.numberRange.contains($0.number) })
            #expect(run.items.map(\.id) == Array(0..<32))
        }
    }

    @Test func everyItemIsShownOnceAndQueriedOnceOnALaterScreen() {
        for seed in Self.seeds {
            let run = makeRun(seed: seed)
            var shownOn: [MemoryItem.ID: Int] = [:]
            var queriedOn: [MemoryItem.ID: Int] = [:]
            var showCount: [MemoryItem.ID: Int] = [:]
            var queryCount: [MemoryItem.ID: Int] = [:]

            for screen in run.screens {
                for field in screen.fields {
                    switch field {
                    case .show(let item):
                        shownOn[item.id] = screen.index
                        showCount[item.id, default: 0] += 1
                    case .query(let item):
                        queriedOn[item.id] = screen.index
                        queryCount[item.id, default: 0] += 1
                    }
                }
            }

            for item in run.items {
                #expect(showCount[item.id] == 1)
                #expect(queryCount[item.id] == 1)
                if let shown = shownOn[item.id], let queried = queriedOn[item.id] {
                    #expect(queried > shown, "Seed \(seed): Item \(item.id) gezeigt auf \(shown), abgefragt auf \(queried)")
                }
            }
        }
    }

    @Test func itemsAreShownInOrder() {
        for seed in Self.seeds.prefix(100) {
            let run = makeRun(seed: seed)
            let shownIDs = run.screens.flatMap { screen in
                screen.fields.filter { !$0.isQuery }.map(\.item.id).sorted()
            }
            #expect(shownIDs == Array(0..<32))
        }
    }

    @Test func queriesInOrderCoversAllItems() {
        let run = makeRun(seed: 42)
        #expect(run.queriesInOrder.count == 32)
        #expect(Set(run.queriesInOrder.map(\.id)) == Set(0..<32))
    }

    @Test func sameSeedGivesSameRun() {
        for seed in Self.seeds.prefix(100) {
            #expect(makeRun(seed: seed) == makeRun(seed: seed))
        }
    }

    @Test func differentSeedsGiveDifferentRuns() {
        #expect(makeRun(seed: 1) != makeRun(seed: 2))
    }

    @Test func fieldPositionsAreMixed() {
        // Auf Bildschirm 3 (2 neu, 2 Abfragen) muss eine Abfrage nicht immer hinten stehen.
        let firstFieldIsQuery = Self.seeds.prefix(200).map { makeRun(seed: $0).screens[2].fields[0].isQuery }
        #expect(firstFieldIsQuery.contains(true))
        #expect(firstFieldIsQuery.contains(false))
    }
}
