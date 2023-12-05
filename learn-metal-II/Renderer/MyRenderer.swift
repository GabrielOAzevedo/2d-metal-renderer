//
//  MyRenderer.swift
//  learn-metal
//
//  Created by Gabriel Azevedo on 01/12/23.
//

import Metal
import MetalKit
import AppKit

class MyRenderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState
    let uniformsBuffer: MTLBuffer
    let GPULock = DispatchSemaphore(value: 1)
    
    var lastRenderTime: CFTimeInterval? = nil
    var currentTime: Double = 0
    var screenSize: Vector2
    
    var shapes: [Shape] = [Rectangle(transform: Transform2D(position: Vector2(128, 128), scale: Vector2(1, 1), rotation: 0))]
    var texture: MTLTexture
    
    init?(mtkView: MTKView) {
        device = mtkView.device!
        commandQueue = device.makeCommandQueue()!
        screenSize = Vector2(Float(mtkView.currentDrawable!.texture.width), Float(mtkView.currentDrawable!.texture.height))
        
        do {
            pipelineState = try MyRenderer.buildRenderPipelineWith(device: device, metalKitView: mtkView)
        } catch {
            print("Unable to compile render pipeline state \(error)")
            return nil
        }
        
        var initialUniforms = Uniforms(brightness: 1, currentTime: Float(currentTime), screen: simd_float2(x: screenSize.x, y: screenSize.y))
        uniformsBuffer = device.makeBuffer(bytes: &initialUniforms, length: MemoryLayout<Uniforms>.stride)!
        
        let loader = MTKTextureLoader(device: device)
        texture = try! loader.newTexture(name: "colored_packed", scaleFactor: 1.0, bundle: nil)
    }
    
    func draw(in view: MTKView) {
        GPULock.wait()
        update(view: view)
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
        
        renderVertices(commandBuffer: commandBuffer, renderPassDescriptor: renderPassDescriptor, view: view)
        
        commandBuffer.addCompletedHandler { _ in
            self.GPULock.signal()
        }
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func renderVertices(commandBuffer: MTLCommandBuffer, renderPassDescriptor: MTLRenderPassDescriptor, view: MTKView) {
        let shapesVertexMap: [Vertex] = shapes.reduce([], {acc, shape in
            var newAcc = acc
            newAcc.append(contentsOf: shape.render(screenSize: screenSize))
            return newAcc
        })
        let vertexBuffer = device.makeBuffer(bytes: shapesVertexMap, length: shapesVertexMap.count * MemoryLayout<Vertex>.stride)!
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentTexture(texture, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: shapesVertexMap.count)
        renderEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
    }
    
    class func buildRenderPipelineWith(device: MTLDevice, metalKitView: MTKView) throws -> MTLRenderPipelineState {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = device.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func update(view: MTKView) {
        let timeDiff = updateTime()
        updateUniforms(dt: timeDiff)
        updateScreenSize(view: view)
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
        ptr.pointee.screen = simd_float2(x: screenSize.x, y: screenSize.y)
    }
    
    func updateScreenSize(view: MTKView) {
        screenSize = Vector2(Float(view.currentDrawable!.texture.width), Float(view.currentDrawable!.texture.height))
    }
}
