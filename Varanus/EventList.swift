//
//  EventList.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

class EventList {
    
    var list = [NSEvent]()
    var lifetime: Double
    
    init(lifetime: Double) {
        self.lifetime = lifetime
    }
    
    func add(event: NSEvent) {
        //TODO: linked list for remove/add in O(1)
        while(!list.isEmpty &&
            list[0].timestamp.distanceTo(event.timestamp) > lifetime) {
                
                list.removeAtIndex(0)
        }
        list.append(event)
    }
    
    func flush() {
        list.removeAll(keepCapacity: false)
    }
    
    func matches(combo: KeyCombo) -> Bool {
        // Fail fast if not enough keys pressed
        if (combo.codes.count != list.count) {
            return false
        }
        for event in list {
            var matched = false
            for code in combo.codes {
                if event.keyCode == code {
                    matched = true
                    break
                }
            }
            if !matched {
                return false
            }
            for mod in combo.mods {
                if !mod.isActive(event) {
                    return false
                }
            }
        }
        self.flush()
        return true
    }
    
}