//
//  Triangle.swift
//  learn-metal-II
//
//  Created by Gabriel Azevedo on 03/12/23.
//

import Foundation

class Triangle: Shape {
    internal var scale: Vector2
    internal var rotation: Float
    private var vertices: [Vertex]
    
    init(
        scale: Vector2 = Vector2(x: 1, y: 1),
        rotation: Float = 0,
        vertices: [Vertex]
    ) {
        self.scale = scale
        self.rotation = rotation
        self.vertices = vertices
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
        self.scale = scale
    }
    
    public func setRotation(angle: Float) {
        self.rotation = angle
    }
    
    public func render() -> ([Vertex]) {
        return applyRotation(angle: self.rotation, vertices: applyScale(scale: self.scale, vertices: self.vertices))
    }
    
}
