//
//  KeyMonitor.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

import Cocoa

public typealias EmptyHandler = Void -> Void
public typealias Handler = KeyCombination -> Void

public enum KeyMask {

    case Up, Down

    func toEventMask() -> NSEventMask {
        switch self {
        case .Up:
            return .KeyUpMask
        case .Down:
            return .KeyDownMask
        }
    }

}

public class KeyMonitor {
    var dict = [KeyCombination: Handler]()
    var list = EventList()

    let lifetime: NSTimeInterval
    let mask: NSEventMask

    var global: AnyObject?
    var local: AnyObject?
    var fallback: Handler?
    var timer: NSTimer?

    public init(lifetime: NSTimeInterval = 0.1, mask: KeyMask = .Down) {
        self.lifetime = lifetime
        self.mask = mask.toEventMask()
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
        global = nil
        return true
    }

    public func stopLocal() -> Bool {
        if local == nil {
            return false
        }
        NSEvent.removeMonitor(local!)
        local = nil
        return true
    }

    func match(combination: KeyCombination) {
        if let handler = dict[combination] {
            list.removeAll()
            async {
                handler(combination)
            }
        } else if let handler = fallback {
            async {
                handler(combination)
            }
        }
    }

    func matchUntilEmpty() {
        let combination = list.joinedCombination()
        while !list.isEmpty() {
            match(combination)
            combination.remove(list.currentCombination()!)
            list.remove()
        }
    }

    func matchUntilUp(to date: NSTimeInterval) {
        let combination = list.joinedCombination()
        while list.hasOlder(than: lifetime, at: date) {
            match(combination)
            combination.remove(list.currentCombination()!)
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
