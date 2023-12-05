//
//  Triangle.swift
//  learn-metal-II
//
//  Created by Gabriel Azevedo on 03/12/23.
//

import Foundation

class Triangle: Shape {
    private var transform: Transform2D
    private var color: Color
    private var vertices: [Vertex]
    
    init(
        transform: Transform2D = Transform2D(position: Vector2(0, 0), scale: Vector2(1, 1), rotation: 0),
        color: Color = Color(255, 255, 255, 1)
    ) {
        self.transform = transform
        self.color = color
        
        let position = transform.position
        self.vertices = [
            Vertex(position: [position.x, position.y + SHAPE_SIZE], color: color.toRGBA(), textureCoordinates: [0, 0]),
            Vertex(position: [position.x - (SHAPE_SIZE), position.y - (SHAPE_SIZE / 2)], color: color.toRGBA(), textureCoordinates: [0, 0]),
            Vertex(position: [position.x + SHAPE_SIZE, position.y - (SHAPE_SIZE / 2)], color: color.toRGBA(), textureCoordinates: [0, 0])
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
