//
//  KeyCombo.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

import Cocoa

/// A key combination representing pressed keys and modifiers.
public class KeyCombination: Printable {

    public var description: String {
        var modifiersDescription = Array(modifiers).map({"\($0), "})
        var codesDescription = Array(codes).map({"\($0), "})
        return "{ modifiers: [\(modifiersDescription)]," +
            " codes: [\(codesDescription)], }"
    }

    /// A set of modifiers.
    public var modifiers = Set<KeyModifier>()

    /// A set of key codes.
    public var codes = Set<KeyCode>()

    init() {}

    init(combination: KeyCombination) {
        modifiers = combination.modifiers
        codes = combination.codes
    }

    /// Initialises a key combination object.
    ///
    /// :param: modifiers A set of modifiers for this combination.
    /// :param: codes A set of key codes for this combination.
    public init(modifiers: Set<KeyModifier>, codes: Set<KeyCode>) {
        self.modifiers = modifiers
        self.codes = codes
    }

    init(event: NSEvent) {
        for modifier in KeyModifier.all {
            if modifier.isIn(event.modifierFlags) {
                modifiers.insert(modifier)
            }
        }
        codes.insert(event.keyCode)
    }

    func add(combination: KeyCombination) {
        modifiers.unionInPlace(combination.modifiers)
        codes.unionInPlace(combination.codes)
    }

    func remove(combination: KeyCombination) {
        //modifiers.subtractInPlace(keyCombination.modifiers)
        codes.subtractInPlace(combination.codes)
    }

}

extension KeyCombination: Hashable {

    /// Hash value for the combination equal to the xor of the components.
    public var hashValue: Int {
        return modifiers.hashValue ^ codes.hashValue
    }

}

/// Equality function defined over the components for the combination.
public func ==(left: KeyCombination, right: KeyCombination) -> Bool {
    return left.modifiers == right.modifiers && left.codes == right.codes
}
