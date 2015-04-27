//
//  EventList.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

class EventNode {

    var next: EventNode?

    let keyCombination: KeyCombination
    let timestamp: NSTimeInterval

    init(event: NSEvent) {
        keyCombination = KeyCombination(event: event)
        timestamp = event.timestamp
    }
    
}

class EventList {

    var start: EventNode?
    var end: EventNode?
    
    init() {}

    func add(event: NSEvent) {
        var node = EventNode(event: event)
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

    func currentKeyCombination() -> KeyCombination? {
        return start?.keyCombination
    }
    
    func joinedKeyCombination() -> KeyCombination {
        var keyCombination = KeyCombination()
        var node = start
        while node != nil {
            keyCombination.add(node!.keyCombination)
            node = node!.next
        }
        return keyCombination
    }

    func hasDifferent(modifiers: Set<KeyModifier>) -> Bool {
        return start?.keyCombination.modifiers != modifiers
    }

    func hasOlder(than lifetime: NSTimeInterval,
        at now: NSTimeInterval) -> Bool {
            return start?.timestamp.distanceTo(now) > lifetime
    }

}
