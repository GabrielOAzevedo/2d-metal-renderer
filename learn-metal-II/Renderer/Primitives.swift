//
//  Primitives.swift
//  learn-metal
//
//  Created by Gabriel Azevedo on 02/12/23.
//

import Foundation

func buildCircle() -> [Vertex] {
    let radius = 0.5
    let vertexCount = 96
    var vertices: [Vertex] = []
    
    let angleStep = 2 * CGFloat.pi / CGFloat(vertexCount)
    for i in 1...vertexCount {
        let angle = angleStep * CGFloat(i)
        let x = radius * cos(angle)
        let y = radius * sin(angle)
        vertices.append(Vertex(position: [simd_float1(x), simd_float1(y)], color: [1, 0, 0, 1], textureCoordinates: [0, 0]))
        let angle2 = angleStep * CGFloat(i+1)
        let x2 = radius * cos(angle2)
        let y2 = radius * sin(angle2)
        vertices.append(Vertex(position: [simd_float1(x2), simd_float1(y2)], color: [1, 0, 0, 1], textureCoordinates: [0, 0]))
        vertices.append(Vertex(position: [0,0], color: [1, 0, 0, 1], textureCoordinates: [0, 0]))
    }
    
    return vertices
}

func rotationMatrix(angle: Float, vertexes: [Vertex]) -> ([Vertex]) {
    let cosTheta = cos(angle)
    let sinTheta = sin(angle)
    
    let rotatedPoints = vertexes.map { vertex in
        var rotatedVertex = vertex
        let rotatedX = cosTheta * vertex.position.x - sinTheta * vertex.position.y
        let rotatedY = sinTheta * vertex.position.x + cosTheta * vertex.position.y
        rotatedVertex.position = [rotatedX, rotatedY]
        return rotatedVertex
    }
    
    return rotatedPoints
}
