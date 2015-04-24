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
    
    func matches(combination: KeyCombination) -> Bool {
        // Fail fast if not enough keys pressed
        if (combination.codes.count != list.count) {
            return false
        }
        var codesCopy = combination.codes
        for event in list {
            var matched = false
            for code in codesCopy {
                if event.keyCode == code {
                    matched = true
                    codesCopy.remove(code)
                    break
                }
            }
            if !matched {
                return false
            }
            for modifier in combination.modifiers {
                if !modifier.isActiveFor(event) {
                    return false
                }
            }
        }
        self.flush()
        return true
    }
    
    func keyCombination() -> KeyCombination {
        var modifiers = Set<KeyModifier>()
        var codes = Set<KeyCode>()
        for event in list {
            codes.insert(event.keyCode)
            for modifier in KeyModifier.all {
                if modifier.isActiveFor(event) {
                    modifiers.insert(modifier)
                }
            }
        }
        return KeyCombination(modifiers: modifiers, codes: codes)
    }

}
