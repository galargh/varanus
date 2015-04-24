//
//  KeyCombo.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

public class KeyCombination {
    
    public var modifiers: Set<KeyModifier>
    public var codes: Set<KeyCode>
    
    public init(modifiers: Set<KeyModifier>, codes: Set<KeyCode>) {
        self.modifiers = modifiers
        self.codes = codes
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
