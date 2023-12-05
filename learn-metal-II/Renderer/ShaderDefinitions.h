//
//  ShaderDefinitions.h
//  learn-metal
//
//  Created by Gabriel Azevedo on 02/12/23.
//

#ifndef ShaderDefinitions_h
#define ShaderDefinitions_h

struct Vertex {
    vector_float2 position;
    vector_float4 color;
    vector_float2 textureCoordinates;
};

struct Uniforms {
    float brightness;
    float currentTime;
    vector_float2 screen;
};

#endif /* ShaderDefinitions_h */
