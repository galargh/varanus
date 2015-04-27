//
//  KeyCombinationPartsTests.swift
//  Varanus
//
//  Created by Piotr Galar on 27/04/2015.
//  Copyright (c) 2015 Piotr Galar. All rights reserved.
//

import XCTest
import Cocoa

class KeyCombinationPartsTests: XCTestCase {

    func testModifierIsInAllFlags() {
        let allFlags = ~NSEventModifierFlags.allZeros

        for modifier in KeyModifier.all {

            XCTAssertTrue(modifier.isIn(allFlags), "Positive check successful")

        }
    }

    func testModifierIsNotInAllZerosFlags() {
        let allZerosFlags = NSEventModifierFlags.allZeros

        for modifier in KeyModifier.all {

            XCTAssertFalse(modifier.isIn(allZerosFlags),
                "Negative check successful")

        }
    }

}
