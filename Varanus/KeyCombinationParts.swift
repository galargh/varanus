//
//  KeyComboParts.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

import Cocoa

/// An alias representing the key code.
public typealias KeyCode = UInt16

/// A key modifier.
///
/// - CapsLock
/// - Shift
/// - Fn
/// - Cmd
/// - Alt
/// - Ctrl
/// - Num
/// - Help
/// - DIM
public enum KeyModifier: CustomStringConvertible {

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
            return flags.isSupersetOf(NSEventModifierFlags.AlphaShiftKeyMask)
        case .Shift:
            return flags.isSupersetOf(NSEventModifierFlags.ShiftKeyMask)
        case .Fn:
            return flags.isSupersetOf(NSEventModifierFlags.FunctionKeyMask)
        case .Cmd:
            return flags.isSupersetOf(NSEventModifierFlags.CommandKeyMask)
        case .Alt:
            return flags.isSupersetOf(NSEventModifierFlags.AlternateKeyMask)
        case .Ctrl:
            return flags.isSupersetOf(NSEventModifierFlags.ControlKeyMask)
        case .Num:
            return flags.isSupersetOf(NSEventModifierFlags.NumericPadKeyMask)
        case .Help:
            return flags.isSupersetOf(NSEventModifierFlags.HelpKeyMask)
        case .DIM:
            return flags.isSupersetOf(
                NSEventModifierFlags.DeviceIndependentModifierFlagsMask)
        }
    }

}
