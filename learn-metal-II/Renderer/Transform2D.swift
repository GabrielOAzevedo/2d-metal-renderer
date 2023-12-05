//
//  Transform.swift
//  learn-metal-II
//
//  Created by Gabriel Azevedo on 02/12/23.
//

import Foundation

struct Vector2 {
    var x: Float
    var y: Float
    
    init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
}

struct Transform2D {
    var position: Vector2
    var scale: Vector2
    var rotation: Float
}
