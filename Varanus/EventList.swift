//
//  EventList.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

import Cocoa

class EventNode {

    var next: EventNode?

    let combination: KeyCombination
    let timestamp: NSTimeInterval

    init(event: NSEvent) {
        combination = KeyCombination(event: event)
        timestamp = event.timestamp
    }

}

class EventList {

    var start: EventNode?
    var end: EventNode?

    init() {}

    func add(event: NSEvent) {
        let node = EventNode(event: event)
        if start == nil {
            start = node
            end = node
        } else {
            end!.next = node
            end = node
        }
    }

    func remove() {
        if start != nil {
            start = start!.next
        }
    }

    func removeAll() {
        start = nil
        end = nil
    }

    func isEmpty() -> Bool {
        return start == nil
    }

    func currentCombination() -> KeyCombination? {
        return start?.combination
    }

    func joinedCombination() -> KeyCombination {
        let combination = KeyCombination()
        var node = start
        while node != nil {
            combination.add(node!.combination)
            node = node!.next
        }
        return combination
    }

    func hasDifferent(modifiers: Set<KeyModifier>) -> Bool {
        return start?.combination.modifiers != modifiers
    }

    func hasOlder(than lifetime: NSTimeInterval,
        at now: NSTimeInterval) -> Bool {
            return start?.timestamp.distanceTo(now) > lifetime
    }

}
