//
//  Shape.swift
//  learn-metal-II
//
//  Created by Gabriel Azevedo on 03/12/23.
//

import Foundation

public let SHAPE_SIZE: Float = 128.0

protocol Shape {
    func render(screenSize: Vector2) -> [Vertex]
    func setRotation(angle: Float)
    func setScale(scale: Vector2)
}
