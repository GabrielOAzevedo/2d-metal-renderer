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
    float2 texCoordinate;
};

float4 orthographicProjection(float left, float right, float top, float bottom, float near, float far, float4 pos) {
    float4x4 orthoMatrix = float4x4(float4(2 / (right - left), 0, 0, 0),
                                    float4(0, 2 / (bottom - top), 0, 0),
                                    float4(0, 0, 1 / (far - near), 0),
                                    float4((left + right) / (left - right), (top + bottom) / (top - bottom), near / (near - far), 1));
    return orthoMatrix * pos;
}


vertex VertexOut vertexShader(
  constant Uniforms &uniforms [[buffer(0)]],
  const device Vertex *vertexArray [[buffer(1)]],
  unsigned int vid [[vertex_id]]
) {
    Vertex in = vertexArray[vid];
    VertexOut out;
    out.color = in.color;
    float4 pos = float4(in.position.x, in.position.y, 0, 1);
    out.pos = orthographicProjection(0, uniforms.screen.x, uniforms.screen.y, 0, 0, 1, pos);
    out.texCoordinate = in.textureCoordinates;
    return out;
}

constexpr sampler s(coord::pixel);
fragment float4 fragmentShader(VertexOut interpolated[[stage_in]], constant Uniforms &uniforms [[buffer(0)]], texture2d<float> colorTexture [[texture(0)]]) {
    return colorTexture.sample(s, float2(interpolated.texCoordinate.x, interpolated.texCoordinate.y));
    //return float4(brightness * interpolated.color.rgb, interpolated.color.a);
}
