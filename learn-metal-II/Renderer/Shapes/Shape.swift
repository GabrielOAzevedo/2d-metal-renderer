//
//  Shape.swift
//  learn-metal-II
//
//  Created by Gabriel Azevedo on 03/12/23.
//

import Foundation

protocol Shape {
    func render() -> [Vertex]
    func setRotation(angle: Float)
    func setScale(scale: Vector2)
}
