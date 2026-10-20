//
//  GameConfigTests.swift
//  Merko32Tests
//

import Testing
@testable import Merko32

struct GameConfigTests {

    @Test func standardConfigIsValid() {
        #expect(GameConfig.standard.validate().isEmpty)
    }

    @Test func standardConfigMatchesRequirements() {
        let config = GameConfig.standard
        #expect(config.screenCount == 16)
        #expect(config.symbols.count * config.colors.count == 36)
        #expect(config.combinationsPerRun == 32)
        #expect(config.numberRange == 11...99)
        #expect(config.secondsPerScreen == [30, 30, 27, 27, 24, 24, 21, 21, 18, 18, 15, 15, 12, 12, 10, 10])
    }

    #if DEBUG
    @Test func debugConfigIsValidWithThreeSeconds() {
        let config = GameConfig.debug
        #expect(config.validate().isEmpty)
        #expect(config.secondsPerScreen.allSatisfy { $0 == 3 })
        #expect(config.secondsPerScreen.count == GameConfig.standard.screenCount)
    }
    #endif

    @Test func tooFewCombinationsIsInvalid() {
        var config = GameConfig.standard
        config.colors.removeLast()  // 6 × 5 = 30 < 32
        #expect(config.validate().contains(.notEnoughCombinations(available: 30, required: 32)))
    }

    @Test func duplicateSymbolsAreInvalid() {
        var config = GameConfig.standard
        config.symbols[1] = config.symbols[0]
        #expect(config.validate().contains(.duplicateSymbols))
    }

    @Test func tooSmallNumberRangeIsInvalid() {
        var config = GameConfig.standard
        config.numberRange = 11...40  // 30 Zahlen < 32
        #expect(config.validate().contains(.numberRangeTooSmall(available: 30, required: 32)))
    }

    @Test func mismatchedArrayLengthsAreInvalid() {
        var config = GameConfig.standard
        config.queryPerScreen.removeLast()
        #expect(config.validate().contains(.arrayLengthMismatch))
    }

    @Test func wrongFieldCountOnScreenIsInvalid() {
        var config = GameConfig.standard
        config.newPerScreen[5] = 3  // 3 + 2 ≠ 4
        let errors = config.validate()
        #expect(errors.contains(.fieldCountMismatch(screen: 5)))
        #expect(errors.contains(.newSumMismatch(sum: 33)))
    }

    @Test func nonPositiveSecondsAreInvalid() {
        var config = GameConfig.standard
        config.secondsPerScreen[3] = 0
        #expect(config.validate().contains(.nonPositiveSeconds(screen: 3)))
    }

    @Test func queryOnFirstScreenViolatesPrefixCondition() {
        var config = GameConfig.standard
        // Bildschirm 1 fragt ab, obwohl noch nichts gezeigt wurde.
        config.newPerScreen[0] = 3; config.queryPerScreen[0] = 1
        config.newPerScreen[1] = 4; config.queryPerScreen[1] = 0
        let errors = config.validate()
        #expect(errors.contains(.notEnoughItemsToQuery(screen: 0)))
        #expect(!errors.contains(.newSumMismatch(sum: 32)))
    }

    @Test func tooManyQueriesEarlyViolatesPrefixCondition() {
        var config = GameConfig.standard
        // Bildschirm 2 fragt alle 4 bisher gezeigten ab, Bildschirm 3 hat dann nichts mehr zum Abfragen.
        // Summen bleiben gleich: neu 3+2+2+2 = 0+2+4+3, Abfrage 1+2+2+2 = 4+2+0+1.
        config.newPerScreen[1] = 0; config.queryPerScreen[1] = 4
        config.newPerScreen[2] = 2; config.queryPerScreen[2] = 2
        config.newPerScreen[3] = 4; config.queryPerScreen[3] = 0
        config.newPerScreen[4] = 3; config.queryPerScreen[4] = 1
        let errors = config.validate()
        #expect(errors == [.notEnoughItemsToQuery(screen: 2)])
    }
}

struct CombinationTests {

    @Test func accessibilityLabelsUseCorrectGermanEndings() {
        #expect(Combination(symbol: .star, color: .red).accessibilityLabel == "roter Stern")
        #expect(Combination(symbol: .heart, color: .yellow).accessibilityLabel == "gelbes Herz")
        #expect(Combination(symbol: .triangle, color: .green).accessibilityLabel == "grünes Dreieck")
        #expect(Combination(symbol: .moon, color: .orange).accessibilityLabel == "orangefarbener Mond")
        #expect(Combination(symbol: .bolt, color: .violet).accessibilityLabel == "violetter Blitz")
    }
}
