//
//  Rectangle.swift
//  learn-metal-II
//
//  Created by Gabriel Azevedo on 03/12/23.
//

import Foundation

let COORD: simd_float1 = 16.0

class Rectangle: Shape {
    internal var transform: Transform2D
    internal var color: Color
    internal var vertices: [Vertex]
    
    init(
        transform: Transform2D = Transform2D(position: Vector2(0, 0), scale: Vector2(1, 1), rotation: 0),
        color: Color = Color(255, 255, 255, 1)
    ) {
        self.transform = transform
        self.color = color
        
        let x = transform.position.x
        let y = transform.position.y
        self.vertices = [
            Vertex(position: [x - SHAPE_SIZE / 2, y + SHAPE_SIZE / 2], color: color.toRGBA(), textureCoordinates: [COORD, COORD]),
            Vertex(position: [x + SHAPE_SIZE / 2, y + SHAPE_SIZE / 2], color: color.toRGBA(), textureCoordinates: [COORD * 2, COORD]),
            Vertex(position: [x + SHAPE_SIZE / 2, y - SHAPE_SIZE / 2], color: color.toRGBA(), textureCoordinates: [COORD * 2, COORD * 2]),
            
            Vertex(position: [x - SHAPE_SIZE / 2, y + SHAPE_SIZE / 2], color: color.toRGBA(), textureCoordinates: [COORD, COORD]),
            Vertex(position: [x - SHAPE_SIZE / 2, y - SHAPE_SIZE / 2], color: color.toRGBA(), textureCoordinates: [COORD, COORD * 2]),
            Vertex(position: [x + SHAPE_SIZE / 2, y - SHAPE_SIZE / 2], color: color.toRGBA(), textureCoordinates: [COORD * 2, COORD * 2]),
        ]
    }
    
    private func applyScale(scale: Vector2, vertices: [Vertex]) -> ([Vertex]) {
        return vertices.map { vertex in
            var newVertex = vertex
            newVertex.position.x = newVertex.position.x * scale.x
            newVertex.position.y = newVertex.position.y * scale.y
            return newVertex
        }
    }
    
    private func applyRotation(angle: Float, vertices: [Vertex]) -> ([Vertex]) {
        let cosTheta = cos(angle)
        let sinTheta = sin(angle)
        
        return vertices.map { vertex in
            var rotatedVertex = vertex
            let rotatedX = cosTheta * vertex.position.x - sinTheta * vertex.position.y
            let rotatedY = sinTheta * vertex.position.x + cosTheta * vertex.position.y
            rotatedVertex.position = [rotatedX, rotatedY]
            return rotatedVertex
        }
    }
    
    public func setScale(scale: Vector2) {
        self.transform.scale = scale
    }
    
    public func setRotation(angle: Float) {
        self.transform.rotation = angle
    }
    
    public func render(screenSize: Vector2) -> ([Vertex]) {
        return applyRotation(angle: self.transform.rotation, vertices: applyScale(scale: self.transform.scale, vertices: self.vertices))
    }
    
}
