//
//  KeyCombo.swift
//  Varanus
//
//  Created by Piotr Galar on 22/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

public class KeyCombo {
    
    var mods: Set<KeyMod>
    var codes: Set<KeyCode>
    
    public init(mods: Set<KeyMod>, codes: Set<KeyCode>) {
        self.mods = mods
        self.codes = codes
    }
    
}

extension KeyCombo: Hashable {
    
    public var hashValue: Int {
        return mods.hashValue ^ codes.hashValue
    }
    
}

public func ==(left: KeyCombo, right: KeyCombo) -> Bool {
    return left.mods == right.mods && left.codes == right.codes
}
