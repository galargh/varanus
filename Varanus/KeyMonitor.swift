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
    
    var dict = [KeyCombo: EventHandler]()
    
    var list: EventList
    var globalListener: AnyObject?
    var localListener: AnyObject?
    
    public init(lifetime: Double = 0.1) {
        list = EventList(lifetime: lifetime)
    }
    
    public func addHandler(combo: KeyCombo, handler: Handler) -> Bool {
        func eventHandler(event: NSEvent!) -> NSEvent! {
            handler()
            return event
        }
        return addEventHandler(combo, handler: eventHandler)
    }
    
    public func addReadOnlyHandler(combo: KeyCombo,
        handler: ReadOnlyHandler) -> Bool {
            func eventHandler(event: NSEvent!) -> NSEvent! {
                handler(event)
                return event
            }
            return addEventHandler(combo, handler: eventHandler)
    }
    
    public func addEventHandler(combo: KeyCombo,
        handler: EventHandler) -> Bool {
            if dict[combo] != nil {
                return false
            }
            dict[combo] = handler
            return true
    }
    
    public func listen(globally: Bool = true) -> Bool {
        if globally {
            if globalListener != nil {
                return false
            }
            globalListener = NSEvent.addGlobalMonitorForEventsMatchingMask(
                NSEventMask.KeyDownMask, handler: globalHandler)
            return globalListener != nil
        } else {
            if localListener != nil {
                return false
            }
            localListener = NSEvent.addLocalMonitorForEventsMatchingMask(
                NSEventMask.KeyDownMask, handler: localHandler)
            return localListener != nil
        }
    }
    
    public func stop(global: Bool = true) -> Bool {
        if global {
            if globalListener == nil {
                return false
            }
            NSEvent.removeMonitor(globalListener!)
        } else {
            if localListener == nil {
                return false
            }
            NSEvent.removeMonitor(localListener!)
        }
        return true
    }
    
    func getEventHandler(event: NSEvent!) -> EventHandler? {
        list.add(event)
        for comboHandler in dict {
            if list.matches(comboHandler.0) {
                return comboHandler.1
            }
        }
        return nil
    }
    
    func globalHandler(event: NSEvent!) {
        if let handler = getEventHandler(event) {
            handler(event)
        }
    }
    
    func localHandler(event: NSEvent!) -> NSEvent! {
        if let handler = getEventHandler(event) {
            return handler(event)
        }
        return event
    }
    
}
