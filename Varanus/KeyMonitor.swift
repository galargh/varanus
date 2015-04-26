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
    var list = EventList()
    var keyCombination = KeyCombination()

    var lifetime: NSTimeInterval
    var mask: NSEventMask

    var global: AnyObject?
    var local: AnyObject?
    var fallback: Handler?

    public init(lifetime: NSTimeInterval = 0.1, keyDown: Bool = true) {
        list = EventList()
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
        return keyCombination
    }

    func match() {
        if let handler = dict[keyCombination] {
            list.removeAll()
            handler()
        } else if let handler = fallback {
            println(keyCombination)
            handler()
        }
    }

    func matchUntilEmpty() {
        keyCombination = list.joinedKeyCombination()
        while !list.isEmpty() {
            match()
            keyCombination.remove(list.currentKeyCombination()!)
            list.remove()
        }
    }

    func remove() {
        if !list.isEmpty() {
            matchUntilEmpty()
        }
    }

    @objc func syncedRemove() {
        sync {
            self.remove()
        }
    }

    func add(event: NSEvent!) {
        if list.hasDifferent(KeyCombination(event: event).modifiers) {
            matchUntilEmpty()
        }
        list.add(event)
        NSTimer.scheduledTimerWithTimeInterval(lifetime, target: self,
            selector: Selector("syncedRemove"), userInfo: nil, repeats: false)
    }

    func syncedAdd(event: NSEvent!) {
        sync {
            self.add(event)
        }
    }

    func globalHandler(event: NSEvent!) {
        syncedAdd(event)
    }

    func localHandler(event: NSEvent!) -> NSEvent! {
        syncedAdd(event)
        return event
    }

    func sync(closure: () -> ()) {
        objc_sync_enter(self)
        closure()
        objc_sync_exit(self)
    }

}
