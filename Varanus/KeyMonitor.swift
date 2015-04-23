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
    var globalListener: AnyObject?
    var localListener: AnyObject?
    
    public init(lifetime: Double = 0.1) {
        list = EventList(lifetime: lifetime)
    }
    
    public func bind(combination: KeyCombination, to handler: Handler) -> Bool {
        func eventHandler(event: NSEvent!) -> NSEvent! {
            handler()
            return event
        }
        return bind(combination, to: eventHandler)
    }
    
    public func bind(combination: KeyCombination,
        to handler: ReadOnlyHandler) -> Bool {
            func eventHandler(event: NSEvent!) -> NSEvent! {
                handler(event)
                return event
            }
            return bind(combination, to: eventHandler)
    }
    
    public func bind(combination: KeyCombination,
        to handler: EventHandler) -> Bool {
            if dict[combination] != nil {
                return false
            }
            dict[combination] = handler
            return true
    }

    public func listenGlobally() -> Bool {
        if globalListener != nil {
            return false
        }
        globalListener = NSEvent.addGlobalMonitorForEventsMatchingMask(
            NSEventMask.KeyDownMask, handler: globalHandler)
        return globalListener != nil
    }
    
    public func listenLocally() -> Bool {
        if localListener != nil {
            return false
        }
        localListener = NSEvent.addLocalMonitorForEventsMatchingMask(
            NSEventMask.KeyDownMask, handler: localHandler)
        return localListener != nil
    }
    
    public func stopGlobalListener() -> Bool {
        if globalListener == nil {
            return false
        }
        NSEvent.removeMonitor(globalListener!)
        return true
    }

    public func stopLocalListener() -> Bool {
        if localListener == nil {
            return false
        }
        NSEvent.removeMonitor(localListener!)
        return true
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
        }
    }
    
    func localHandler(event: NSEvent!) -> NSEvent! {
        if let handler = handlerFor(event) {
            return handler(event)
        }
        return event
    }
    
}
