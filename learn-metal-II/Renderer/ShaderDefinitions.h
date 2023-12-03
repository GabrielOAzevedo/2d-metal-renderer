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
};

struct Uniforms {
    float brightness;
    float currentTime;
};

#endif /* ShaderDefinitions_h */
