//
//  KeyMonitor.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

import Cocoa

/// A Void -> Void handler.
public typealias EmptyHandler = Void -> Void

/// A KeyCombination -> Void handler.
public typealias Handler = KeyCombination -> Void

/// A subset of NSEventMask related to key events.
///
/// - Up: a key up mask
/// - Down: a key down mask
public enum KeyMask {

    case Up, Down

    func toEventMask() -> NSEventMask {
        switch self {
        case .Up: return .KeyUpMask
        case .Down: return .KeyDownMask
        }
    }

}

/// A monitor for both global and local key down or up events
public class KeyMonitor {

    var dict = [KeyCombination: Handler]()
    var list = EventList()

    let lifetime: NSTimeInterval
    let mask: NSEventMask

    var global: AnyObject?
    var local: AnyObject?
    var fallback: Handler?
    var timer: NSTimer?

    /// Initialises a key monitor object.
    ///
    /// :param: lifetime A time interval specifying how long a key event should
    ///   be kept alive and considered a part of the current key combination.
    /// :param: mask A key event mask specyfying wether KeyDown or KeyUp events
    ///   should be registered.
    public init(lifetime: NSTimeInterval = 0.1, mask: KeyMask = .Down) {
        self.lifetime = lifetime
        self.mask = mask.toEventMask()
    }

    /// Binds a key combination to a void handler.
    ///
    /// :param: combination A key combination.
    /// :param: handler A Void -> Void handler.
    public func bind(combination: KeyCombination, to handler: EmptyHandler) {
        func wrappedHandler(combination: KeyCombination) {
            handler()
        }
        dict[combination] = wrappedHandler
    }

    /// Binds a key combination to a handler.
    ///
    /// :param: combination A key combination.
    /// :param: handler A KeyCombination -> Void handler.
    public func bind(combination: KeyCombination, to handler: Handler) {
        dict[combination] = handler
    }

    /// Registers void handler as a fallback.
    ///
    /// :param: fallback A Void -> Void handler.
    public func register(fallback: EmptyHandler) {
        func wrappedFallback(combination: KeyCombination) {
            fallback()
        }
        self.fallback = wrappedFallback
    }

    /// Registers fallback.
    ///
    /// :param: fallback A KeyCombination -> Void handler.
    public func register(fallback: Handler) {
        self.fallback = fallback
    }

    /// Unregisters fallback.
    public func unregister() {
        fallback = nil
    }

    /// Unbinds a key combination.
    ///
    /// :param: combination A key combination.
    public func unbind(combination: KeyCombination) {
        dict[combination] = nil
    }

    /// Starts a global key monitor.
    ///
    /// :returns: True if global key monitor was started; false otherwise.
    public func startGlobal() -> Bool {
        if global != nil {
            return false
        }
        global = NSEvent.addGlobalMonitorForEventsMatchingMask(mask,
            handler: globalHandler)
        return global != nil
    }

    /// Starts a local key monitor.
    ///
    /// :returns: True if local key monitor was started; false otherwise.
    public func startLocal() -> Bool {
        if local != nil {
            return false
        }
        local = NSEvent.addLocalMonitorForEventsMatchingMask(mask,
            handler: localHandler)
        return local != nil
    }

    /// Stops a global key monitor.
    ///
    /// :returns: True if global key monitor was stopped; false otherwise.
    public func stopGlobal() -> Bool {
        if global == nil {
            return false
        }
        NSEvent.removeMonitor(global!)
        global = nil
        return true
    }

    /// Stops a local key monitor.
    ///
    /// :returns: True if local key monitor was stopped; false otherwise.
    public func stopLocal() -> Bool {
        if local == nil {
            return false
        }
        NSEvent.removeMonitor(local!)
        local = nil
        return true
    }

    func match(combination: KeyCombination) -> Bool {
        if let handler = dict[combination] {
            async {
                handler(combination)
            }
            return true
        } else if let handler = fallback {
            async {
                handler(combination)
            }
        }
        return false
    }

    func matchUntilEmpty() {
        let combination = list.joinedCombination()
        while !list.isEmpty() {
            if match(combination) {
                list.removeAll()
                return
            }
            combination.remove(list.currentCombination()!)
            list.remove()
        }
    }

    func matchUntilUp(to date: NSTimeInterval) {
        let combination = list.joinedCombination()
        while list.hasOlder(than: lifetime, at: date) {
            if match(combination) {
                list.removeAll()
                return
            }
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
