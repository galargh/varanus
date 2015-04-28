//
//  KeyMonitorTests.swift
//  Varanus
//
//  Created by Piotr Galar on 27/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

import XCTest
import Cocoa

class KeyMonitorTests: XCTestCase {

    let event = NSEvent.keyEventWithType(.KeyDown, location: .zeroPoint,
        modifierFlags: .ShiftKeyMask, timestamp: 0.1, windowNumber: 0,
        context: nil, characters: "A", charactersIgnoringModifiers: "a",
        isARepeat: false, keyCode: 0)!
    let combination = KeyCombination(modifiers: [.Shift], codes: [0])

    func emptyHandler() {}
    func handler(combination: KeyCombination) {}

    func testKeyMaskUp() {
        XCTAssertEqual(NSEventMask.KeyUpMask, KeyMask.Up.toEventMask())
    }

    func testKeyMaskDown() {
        XCTAssertEqual(NSEventMask.KeyDownMask, KeyMask.Down.toEventMask())
    }

    func testInit() {
        let monitor = KeyMonitor()

        XCTAssertEqual(monitor.dict.count, 0)
        XCTAssertTrue(monitor.list.start == nil)
        XCTAssertEqual(monitor.lifetime, 0.1)
        XCTAssertEqual(monitor.mask, NSEventMask.KeyDownMask)
        XCTAssertNil(monitor.global)
        XCTAssertNil(monitor.local)
        XCTAssertTrue(monitor.fallback == nil)
        XCTAssertNil(monitor.timer)
    }

    func testBindEmptyHandler() {
        let monitor = KeyMonitor()

        monitor.bind(combination, to: emptyHandler)

        XCTAssertTrue(monitor.dict[combination] != nil)
    }

    func testBindHandler() {
        let monitor = KeyMonitor()

        monitor.bind(combination, to: handler)

        XCTAssertTrue(monitor.dict[combination] != nil)
    }

    func testRegisterFallback() {
        let monitor = KeyMonitor()

        monitor.register(handler)

        XCTAssertTrue(monitor.fallback != nil)
    }

    func testUnbindCombination() {
        let monitor = KeyMonitor()
        monitor.bind(combination, to: handler)

        monitor.unbind(combination)

        XCTAssertTrue(monitor.dict[combination] == nil)
    }

    func testUnregisterFallback() {
        let monitor = KeyMonitor()
        monitor.register(handler)

        monitor.unregister()

        XCTAssertTrue(monitor.fallback == nil)
    }

    func testStartAndStopGlobal() {
        let monitor = KeyMonitor()

        XCTAssertTrue(monitor.startGlobal())
        XCTAssertFalse(monitor.startGlobal())
        XCTAssertTrue(monitor.stopGlobal())
        XCTAssertFalse(monitor.stopGlobal())
    }

    func testStartAndStopLocal() {
        let monitor = KeyMonitor()

        XCTAssertTrue(monitor.startLocal())
        XCTAssertFalse(monitor.startLocal())
        XCTAssertTrue(monitor.stopLocal())
        XCTAssertFalse(monitor.stopLocal())
    }

}
