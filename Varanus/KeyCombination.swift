//
//  KeyCombo.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

public class KeyCombination: Printable {

    public var description: String {
        var modifiersString = "["
        for modifier in modifiers {
            modifiersString += modifier.description + ", "
        }
        modifiersString += "]"
        var codesString = "["
        for code in codes {
            codesString += String(code) + ", "
        }
        codesString += "]"
        return "{ modifiers: \(modifiersString), codes: \(codesString), }"
    }

    var modifiers = Set<KeyModifier>()
    var codes = Set<KeyCode>()

    init() {}

    init(keyCombination: KeyCombination) {
        modifiers = keyCombination.modifiers
        codes = keyCombination.codes
    }

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

    public func modifiersSet() -> Set<KeyModifier> {
        return modifiers
    }

    public func codesSet() -> Set<KeyCode> {
        return codes
    }

    func add(keyCombination: KeyCombination) {
        //modifiers.unionInPlace(keyCombination.modifiers)
        codes.unionInPlace(keyCombination.codes)
    }

    func remove(keyCombination: KeyCombination) {
        //modifiers.subtractInPlace(keyCombination.modifiers)
        codes.subtractInPlace(keyCombination.codes)
    }

}

extension KeyCombination: Hashable {

    public var hashValue: Int {
        return modifiers.hashValue ^ codes.hashValue
    }

}

public func ==(left: KeyCombination, right: KeyCombination) -> Bool {
    return left.modifiers == right.modifiers && left.codes == right.codes
}
