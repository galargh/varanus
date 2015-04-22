//
//  KeyComboParts.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

public typealias KeyCode = UInt16

public enum KeyMod {
    
    case CapsLock, Shift, Fn, Cmd, Alt, Ctrl, Num, Help, DIM
    
    public func isActive(event: NSEvent!) -> Bool {
        switch self {
        case .CapsLock:
            return isModActive(event,
                flag: NSEventModifierFlags.AlphaShiftKeyMask)
        case .Shift:
            return isModActive(event,
                flag: NSEventModifierFlags.ShiftKeyMask)
        case .Fn:
            return isModActive(event,
                flag: NSEventModifierFlags.FunctionKeyMask)
        case .Cmd:
            return isModActive(event,
                flag: NSEventModifierFlags.CommandKeyMask)
        case .Alt:
            return isModActive(event,
                flag: NSEventModifierFlags.AlternateKeyMask)
        case .Ctrl:
            return isModActive(event,
                flag: NSEventModifierFlags.ControlKeyMask)
        case .Num:
            return isModActive(event,
                flag: NSEventModifierFlags.NumericPadKeyMask)
        case .Help:
            return isModActive(event,
                flag: NSEventModifierFlags.HelpKeyMask)
        case .DIM:
            return isModActive(event,
                flag: NSEventModifierFlags.DeviceIndependentModifierFlagsMask)
        }
    }
    
    func isModActive(event: NSEvent!, flag: NSEventModifierFlags) -> Bool {
        return (event.modifierFlags & flag) == flag
    }
    
}

