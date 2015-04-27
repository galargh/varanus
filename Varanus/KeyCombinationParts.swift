//
//  KeyComboParts.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

import Cocoa

public typealias KeyCode = UInt16

public enum KeyModifier: Printable {

    public var description: String {
        switch self {
        case .CapsLock: return "CapsLock"
        case .Shift: return "Shift"
        case .Fn: return "Fn"
        case .Cmd: return "Cmd"
        case .Alt: return "Alt"
        case .Ctrl: return "Ctrl"
        case .Num: return "Num"
        case .Help: return "Help"
        case .DIM: return "DIM"
        }
    }

    case CapsLock, Shift, Fn, Cmd, Alt, Ctrl, Num, Help, DIM

    static let all = [CapsLock, Shift, Fn, Cmd, Alt, Ctrl, Num, Help, DIM]

    func isIn(flags: NSEventModifierFlags) -> Bool {
        switch self {
        case .CapsLock:
            return isIn(flags, with: NSEventModifierFlags.AlphaShiftKeyMask)
        case .Shift:
            return isIn(flags, with: NSEventModifierFlags.ShiftKeyMask)
        case .Fn:
            return isIn(flags, with: NSEventModifierFlags.FunctionKeyMask)
        case .Cmd:
            return isIn(flags, with: NSEventModifierFlags.CommandKeyMask)
        case .Alt:
            return isIn(flags, with: NSEventModifierFlags.AlternateKeyMask)
        case .Ctrl:
            return isIn(flags, with: NSEventModifierFlags.ControlKeyMask)
        case .Num:
            return isIn(flags, with: NSEventModifierFlags.NumericPadKeyMask)
        case .Help:
            return isIn(flags, with: NSEventModifierFlags.HelpKeyMask)
        case .DIM:
            return isIn(flags,
                with: NSEventModifierFlags.DeviceIndependentModifierFlagsMask)
        }
    }

    func isIn(flags: NSEventModifierFlags,
        with flag: NSEventModifierFlags) -> Bool {
            return (flags & flag) == flag
    }

}

