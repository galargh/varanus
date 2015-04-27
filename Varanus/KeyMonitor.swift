//
//  KeyMonitor.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

public typealias EmptyHandler = Void -> Void
public typealias Handler = KeyCombination -> Void

public class KeyMonitor {

    var dict = [KeyCombination: Handler]()
    var list = EventList()

    var lifetime: NSTimeInterval
    var mask: NSEventMask

    var global: AnyObject?
    var local: AnyObject?
    var fallback: Handler?
    var timer: NSTimer?

    public init(lifetime: NSTimeInterval = 0.1, keyDown: Bool = true) {
        list = EventList()
        self.lifetime = lifetime
        mask = keyDown ? .KeyDownMask : .KeyUpMask
    }

    public func bind(combination: KeyCombination?, to handler: EmptyHandler) {
        func wrappedHandler(keyCombination: KeyCombination) {
            handler()
        }
        bind(combination, to: wrappedHandler)
    }

    public func bind(combination: KeyCombination?, to handler: Handler) {
        if let keyCombination = combination {
            dict[keyCombination] = handler
        } else {
            fallback = handler
        }
    }

    public func unbind(combination: KeyCombination?) {
        if let keyCombination = combination {
            dict[keyCombination] = nil
        } else {
            fallback = nil
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

    func match(keyCombination: KeyCombination) {
        if let handler = dict[keyCombination] {
            list.removeAll()
            async {
                handler(keyCombination)
            }
        } else if let handler = fallback {
            //println(keyCombination)
            async {
                handler(keyCombination)
            }
        }
    }

    func matchUntilEmpty() {
        var keyCombination = list.joinedKeyCombination()
        while !list.isEmpty() {
            match(keyCombination)
            keyCombination.remove(list.currentKeyCombination()!)
            list.remove()
        }
    }

    func matchUntilUp(to date: NSTimeInterval) {
        var keyCombination = list.joinedKeyCombination()
        while list.hasOlder(than: lifetime, at: date) {
            match(keyCombination)
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
        timer?.invalidate()
        if list.hasDifferent(KeyCombination(event: event).modifiers) {
            matchUntilEmpty()
        }
        if list.hasOlder(than: lifetime, at: event.timestamp) {
            matchUntilUp(to: event.timestamp)
        }
        list.add(event)
        timer = NSTimer.scheduledTimerWithTimeInterval(lifetime, target: self,
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

    func async(closure: () -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            closure()
        }
    }

}
