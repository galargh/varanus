//
//  KeyCombinationTests.swift
//  Varanus
//
//  Created by Piotr Galar on 27/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

import XCTest
import Cocoa

class KeyCombinationTests: XCTestCase {

    func testInit() {
        let combination = KeyCombination()

        XCTAssertEqual(combination.modifiers.count, 0)
        XCTAssertEqual(combination.codes.count, 0)
    }

    func testInitWithModifiersAndCodes() {
        let modifiers: Set<KeyModifier> = [.Shift, .Cmd]
        let codes: Set<KeyCode> = [0, 1]

        let combination = KeyCombination(modifiers: modifiers, codes: codes)

        XCTAssertEqual(combination.modifiers, modifiers)
        XCTAssertEqual(combination.codes, codes)
    }

    func testInitWithCombination() {
        let modifiers: Set<KeyModifier> = [.Shift, .Cmd]
        let codes: Set<KeyCode> = [0, 1]
        let combination = KeyCombination(modifiers: modifiers, codes: codes)

        let copy = KeyCombination(combination: combination)

        XCTAssertEqual(copy, combination)
    }

    func testHashValue() {
        let modifiers: Set<KeyModifier> = [.Shift, .Cmd]
        let codes: Set<KeyCode> = [0, 1]
        let hashValue = modifiers.hashValue ^ codes.hashValue

        let combinationHash = KeyCombination(modifiers: modifiers,
            codes: codes).hashValue

        XCTAssertEqual(combinationHash, hashValue)
    }

    func testInitWithEvent() {
        let event = NSEvent.keyEventWithType(.KeyDown, location: .zeroPoint,
            modifierFlags: .ShiftKeyMask, timestamp: .infinity, windowNumber: 0,
            context: nil, characters: "S", charactersIgnoringModifiers: "s",
            isARepeat: false, keyCode: 1)!
        let modifiers: Set<KeyModifier> = [.Shift]
        let codes: Set<KeyCode> = [1]

        let combination = KeyCombination(event: event)

        XCTAssertEqual(combination.modifiers, modifiers)
        XCTAssertEqual(combination.codes, codes)
    }

    func testAdd() {
        let combination = KeyCombination(modifiers: [.Shift], codes: [0])
        let other = KeyCombination(modifiers: [.Cmd], codes: [1])
        let modifiers: Set<KeyModifier> = [.Shift, .Cmd]
        let codes: Set<KeyCode> = [0, 1]

        combination.add(other)

        XCTAssertNotEqual(combination, other)
        XCTAssertEqual(combination.modifiers, modifiers)
        XCTAssertEqual(combination.codes, codes)
    }

    func testRemove() {
        let combination = KeyCombination(modifiers: [.Shift, .Cmd],
            codes: [0, 1])
        let other = KeyCombination(modifiers: [.Cmd], codes: [1])
        let modifiers: Set<KeyModifier> = [.Shift, .Cmd]
        let codes: Set<KeyCode> = [0]

        combination.remove(other)

        XCTAssertNotEqual(combination, other)
        XCTAssertEqual(combination.modifiers, modifiers)
        XCTAssertEqual(combination.codes, codes)
    }

}
