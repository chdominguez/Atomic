//
//  Extensions.swift
//  Atomic
//
//  Created by Christian Dominguez on 5/1/22.
//

import CoreGraphics

extension Double {
    func stringWith(_ decimals: Int) -> String {
        return String(format: "%.\(decimals)f", self)
    }
}

extension CGFloat {
    func stringWith(_ decimals: Int) -> String {
        if self < 0 {
            return String(format: "%.\(decimals)f", self)
        }
        else {
            return " \(String(format: "%.\(decimals)f", self))"
        }
    }
}
