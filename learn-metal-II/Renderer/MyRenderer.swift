//
//  MyRenderer.swift
//  learn-metal
//
//  Created by Gabriel Azevedo on 01/12/23.
//

import Metal
import MetalKit

class MyRenderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState
    let uniformsBuffer: MTLBuffer
    let GPULock = DispatchSemaphore(value: 1)
    
    var lastRenderTime: CFTimeInterval? = nil
    var currentTime: Double = 0
    
    var shapes: [Shape] = [Rectangle(scale: Vector2(x: 0.5, y: 0.5), rotation: 0, vertices: [
        Vertex(position: [-1, 1], color: [1, 0, 0, 1]),
        Vertex(position: [1, 1], color: [1, 0, 0, 1]),
        Vertex(position: [1, -1], color: [1, 0, 0, 1]),
        Vertex(position: [-1, 1], color: [1, 0, 0, 1]),
        Vertex(position: [-1, -1], color: [1, 0, 0, 1]),
        Vertex(position: [1, -1], color: [1, 0, 0, 1]),
    ]), Triangle(scale: Vector2(x: 0.5, y: 0.5), rotation: 0, vertices: [
        Vertex(position: [-1, -1], color: [1, 0, 0, 1]),
        Vertex(position: [1, -1], color: [0, 1, 0, 1]),
        Vertex(position: [0, 1], color: [0, 0, 1, 1])
    ])]
    
    init?(mtkView: MTKView) {
        device = mtkView.device!
        commandQueue = device.makeCommandQueue()!
        
        do {
            pipelineState = try MyRenderer.buildRenderPipelineWith(device: device, metalKitView: mtkView)
        } catch {
            print("Unable to compile render pipeline state \(error)")
            return nil
        }
        
        var initialUniforms = Uniforms(brightness: 1, currentTime: Float(currentTime))
        uniformsBuffer = device.makeBuffer(bytes: &initialUniforms, length: MemoryLayout<Uniforms>.stride)!
    }
    
    func draw(in view: MTKView) {
        GPULock.wait()
        let timeDiff = updateTime()
        updateUniforms(dt: timeDiff)
        updateVertices(dt: timeDiff)
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        let shapesVertexMap: [Vertex] = shapes.reduce([], {acc, shape in
            var newAcc = acc
            newAcc.append(contentsOf: shape.render())
            return newAcc
        })
        let vertexBuffer = device.makeBuffer(bytes: shapesVertexMap, length: shapesVertexMap.count * MemoryLayout<Vertex>.stride)!
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 1)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: shapesVertexMap.count)
        renderEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.addCompletedHandler { _ in
            self.GPULock.signal()
        }
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    class func buildRenderPipelineWith(device: MTLDevice, metalKitView: MTKView) throws -> MTLRenderPipelineState {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = device.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func updateTime() -> Double {
        let systemTime = CACurrentMediaTime()
        let timeDifference = (lastRenderTime == nil) ? 0 : (systemTime - lastRenderTime!)
        lastRenderTime = systemTime
        return timeDifference
    }
    
    func updateUniforms(dt: CFTimeInterval) {
        let ptr = uniformsBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
        currentTime += dt
        ptr.pointee.currentTime = Float(currentTime)
    }
    
    func updateVertices(dt: CFTimeInterval) {
        let scale = Float(0.1 * cos(currentTime) + 0.8)
        let rotation = Float(currentTime / 3.14)
        shapes.forEach{ shape in
            shape.setRotation(angle: rotation)
            shape.setScale(scale: Vector2(x: scale, y: scale))
        }
    }
}
