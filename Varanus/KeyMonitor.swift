//
//  KeyMonitor.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

public typealias Handler = Void -> Void
public typealias ReadOnlyHandler = NSEvent! -> Void
public typealias EventHandler = NSEvent! -> NSEvent!

public class KeyMonitor {
    
    var dict = [KeyCombination: EventHandler]()
    
    var list: EventList
    var global: AnyObject?
    var local: AnyObject?
    var fallback: EventHandler?
    
    public init(lifetime: Double = 0.1) {
        list = EventList(lifetime: lifetime)
    }
    
    public func bind(combination: KeyCombination?, to handler: Handler) {
        func eventHandler(event: NSEvent!) -> NSEvent! {
            handler()
            return event
        }
        bind(combination, to: eventHandler)
    }
    
    public func bind(combination: KeyCombination?,
        to handler: ReadOnlyHandler) {
            func eventHandler(event: NSEvent!) -> NSEvent! {
                handler(event)
                return event
            }
            bind(combination, to: eventHandler)
    }
    
    public func bind(combination: KeyCombination?, to handler: EventHandler) {
        if let defined = combination {
            dict[defined] = handler
        } else {
            fallback = handler
        }
    }

    public func startGlobal() -> Bool {
        if global != nil {
            return false
        }
        global = NSEvent.addGlobalMonitorForEventsMatchingMask(
            NSEventMask.KeyDownMask, handler: globalHandler)
        return global != nil
    }
    
    public func startLocal() -> Bool {
        if local != nil {
            return false
        }
        local = NSEvent.addLocalMonitorForEventsMatchingMask(
            NSEventMask.KeyDownMask, handler: localHandler)
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

    func handlerFor(event: NSEvent!) -> EventHandler? {
        list.add(event)
        for combinationHandler in dict {
            if list.matches(combinationHandler.0) {
                return combinationHandler.1
            }
        }
        return nil
    }
    
    func globalHandler(event: NSEvent!) {
        if let handler = handlerFor(event) {
            handler(event)
        } else if let defined = fallback {
            defined(event)
        }
    }
    
    func localHandler(event: NSEvent!) -> NSEvent! {
        if let handler = handlerFor(event) {
            return handler(event)
        } else if let defined = fallback {
            return defined(event)
        }
        return event
    }
    
}
