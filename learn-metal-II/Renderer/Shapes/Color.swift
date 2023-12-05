//
//  Color.swift
//  learn-metal-II
//
//  Created by Gabriel Azevedo on 03/12/23.
//

import Foundation

class Color {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var alpha: Float
    
    init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ alpha: Float = 1) {
        self.r = r
        self.g = g
        self.b = b
        self.alpha = alpha
    }
    
    func toRGBA() -> simd_float4 {
        return [Float(r), Float(g), Float(b), alpha]
    }
}
