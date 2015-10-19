//
//  EventListTests.swift
//  Varanus
//
//  Created by Piotr Galar on 27/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

import XCTest
import Cocoa

extension EventNode: Hashable {

    var hashValue: Int {
        return combination.hashValue ^ timestamp.hashValue
    }

}

func ==(left: EventNode, right: EventNode) -> Bool {
    return left.combination == right.combination &&
        left.timestamp == right.timestamp
}

class EventListTests: XCTestCase {

    let event = NSEvent.keyEventWithType(.KeyDown, location: .zero,
        modifierFlags: .ShiftKeyMask, timestamp: 0.1, windowNumber: 0,
        context: nil, characters: "S", charactersIgnoringModifiers: "s",
        isARepeat: false, keyCode: 1)!
    let otherEvent = NSEvent.keyEventWithType(.KeyDown, location: .zero,
        modifierFlags: .CommandKeyMask, timestamp: 0.2, windowNumber: 0,
        context: nil, characters: "a", charactersIgnoringModifiers: "a",
        isARepeat: false, keyCode: 0)!

    func testEventNodeInit() {
        let combination = KeyCombination(event: event)

        let node = EventNode(event: event)

        XCTAssertEqual(node.combination, combination)
        XCTAssertEqual(node.timestamp, event.timestamp)
        XCTAssertNil(node.next)
    }

    func testEventListInit() {
        let list = EventList()

        XCTAssertNil(list.start)
        XCTAssertNil(list.end)
    }

    func testAddToEmptyList() {
        let list = EventList()
        let node = EventNode(event: event)

        list.add(event)

        XCTAssertEqual(list.start!, list.end!)
        XCTAssertEqual(list.start!, node)
    }

    func testAddToNonEmptyList() {
        let list = EventList()
        let node = EventNode(event: otherEvent)
        list.add(event)

        list.add(otherEvent)

        XCTAssertNotEqual(list.start!, list.end!)
        XCTAssertEqual(list.end!, node)
        XCTAssertEqual(list.start!.next!, node)
    }

    func testRemoveFromEmptyList() {
        let list = EventList()

        list.remove()

        XCTAssertNil(list.start)
        XCTAssertNil(list.end)
    }

    func testRemoveFromNonEmptyList() {
        let list = EventList()
        let node = EventNode(event: otherEvent)
        list.add(event)
        list.add(otherEvent)

        list.remove()

        XCTAssertEqual(list.start!, list.end!)
        XCTAssertEqual(list.start!, node)
    }

    func testRemoveAll() {
        let list = EventList()
        list.add(event)
        list.add(otherEvent)

        list.removeAll()

        XCTAssertNil(list.start)
        XCTAssertNil(list.end)
    }

    func testIsEmptyForEmptyList() {
        let list = EventList()

        XCTAssertTrue(list.isEmpty())
    }

    func testIsEmptyForNonEmptyList() {
        let list = EventList()
        list.add(event)

        XCTAssertFalse(list.isEmpty())
    }

    func testCurrentCombination() {
        let list = EventList()
        let combination = KeyCombination(event: event)
        list.add(event)
        list.add(otherEvent)

        XCTAssertEqual(list.currentCombination()!, combination)
    }

    func testJoinedCombination() {
        let list = EventList()
        let combination = KeyCombination(modifiers: [.Shift, .Cmd], codes: [0, 1])
        list.add(event)
        list.add(otherEvent)

        XCTAssertEqual(list.joinedCombination(), combination)
    }

    func testHasDifferentModifiers() {
        let list = EventList()
        let modifiers: Set<KeyModifier> = [.Shift]
        let otherModifiers: Set<KeyModifier> = [.Cmd]
        list.add(event)
        list.add(otherEvent)

        XCTAssertFalse(list.hasDifferent(modifiers))
        XCTAssertTrue(list.hasDifferent(otherModifiers))
    }

    func testHasOlderThan() {
        let list = EventList()
        list.add(event)
        list.add(otherEvent)

        XCTAssertFalse(list.hasOlder(than: 0.3, at: 0.3))
        XCTAssertTrue(list.hasOlder(than: 0.1, at: 0.3))
    }

}
