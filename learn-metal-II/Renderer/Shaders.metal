//
//  Shaders.metal
//  learn-metal
//
//  Created by Gabriel Azevedo on 02/12/23.
//

#include <metal_stdlib>
#include "ShaderDefinitions.h"
using namespace metal;

struct VertexOut {
    float4 color;
    float4 pos [[position]];
};

vertex VertexOut vertexShader(
  constant Uniforms &uniforms [[buffer(0)]],
  const device Vertex *vertexArray [[buffer(1)]],
  unsigned int vid [[vertex_id]]
) {
    Vertex in = vertexArray[vid];
    VertexOut out;
    out.color = in.color;
    out.pos = float4(in.position.x, in.position.y, 0, 1);
    return out;
}

fragment float4 fragmentShader(VertexOut interpolated[[stage_in]], constant Uniforms &uniforms [[buffer(0)]]) {
    float brightness = 1; //0.5 * cos(uniforms.currentTime) + 0.5;
    return float4(brightness * interpolated.color.rgb, interpolated.color.a);
}
