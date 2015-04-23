//
//  KeyComboParts.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

public typealias KeyCode = UInt16

public enum KeyModifier {
    
    case CapsLock, Shift, Fn, Cmd, Alt, Ctrl, Num, Help, DIM
    
    public func isActiveFor(event: NSEvent!) -> Bool {
        switch self {
        case .CapsLock:
            return isActiveFor(event,
                with: NSEventModifierFlags.AlphaShiftKeyMask)
        case .Shift:
            return isActiveFor(event,
                with: NSEventModifierFlags.ShiftKeyMask)
        case .Fn:
            return isActiveFor(event,
                with: NSEventModifierFlags.FunctionKeyMask)
        case .Cmd:
            return isActiveFor(event,
                with: NSEventModifierFlags.CommandKeyMask)
        case .Alt:
            return isActiveFor(event,
                with: NSEventModifierFlags.AlternateKeyMask)
        case .Ctrl:
            return isActiveFor(event,
                with: NSEventModifierFlags.ControlKeyMask)
        case .Num:
            return isActiveFor(event,
                with: NSEventModifierFlags.NumericPadKeyMask)
        case .Help:
            return isActiveFor(event,
                with: NSEventModifierFlags.HelpKeyMask)
        case .DIM:
            return isActiveFor(event,
                with: NSEventModifierFlags.DeviceIndependentModifierFlagsMask)
        }
    }
    
    func isActiveFor(event: NSEvent!, with flag: NSEventModifierFlags) -> Bool {
        return (event.modifierFlags & flag) == flag
    }
    
}

