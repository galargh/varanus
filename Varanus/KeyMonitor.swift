//
//  KeyMonitor.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

public typealias Handler = Void -> Void

public class KeyMonitor {
    
    var dict = [KeyCombination: Handler]()
    
    var list: EventList
    var lifetime: Double
    var mask: NSEventMask

    var global: AnyObject?
    var local: AnyObject?
    var fallback: Handler?
    var timer: NSTimer?
    
    public init(lifetime: Double = 0.1, keyDown: Bool = true) {
        list = EventList(lifetime: lifetime)
        self.lifetime = lifetime
        mask = keyDown ? .KeyDownMask : .KeyUpMask
    }
    
    public func bind(combination: KeyCombination?, to handler: Handler) {
        if let keyCombination = combination {
            dict[keyCombination] = handler
        } else {
            fallback = handler
        }
    }

    public func startGlobal() -> Bool {
        if global != nil {
            return false
        }
        global = NSEvent.addGlobalMonitorForEventsMatchingMask(mask,
            handler: globalHandler)
        return global != nil
    }
    
    public func startLocal() -> Bool {
        if local != nil {
            return false
        }
        local = NSEvent.addLocalMonitorForEventsMatchingMask(mask,
            handler: localHandler)
        return local != nil
    }
    
    public func stopGlobal() -> Bool {
        if global == nil {
            return false
        }
        NSEvent.removeMonitor(global!)
        return true
    }

    public func stopLocal() -> Bool {
        if local == nil {
            return false
        }
        NSEvent.removeMonitor(local!)
        return true
    }
    
    public func currentKeyCombination() -> KeyCombination {
        return list.keyCombination()
    }

    @objc func handleCurrentKeyCombination() {
        for (combination, handler) in dict {
            if list.matches(combination) {
                handler()
                return
            }
        }
        if let f = fallback {
            f()
        }
    }

    func handlerFor(event: NSEvent!) {
        list.add(event)

        // Thread-safety&handling combination when removing events from the list
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(lifetime, target: self,
            selector: Selector("handleCurrentKeyCombination"), userInfo: nil,
            repeats: false)
    }

    func globalHandler(event: NSEvent!) {
        handlerFor(event)
    }
    
    func localHandler(event: NSEvent!) -> NSEvent! {
        handlerFor(event)
        return event
    }
    
}
