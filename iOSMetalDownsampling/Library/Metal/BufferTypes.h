//
//  BufferTypes.h
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 5/23/15.
//  Copyright (c) 2015 Bradley Griffith. All rights reserved.
//

#import <simd/simd.h>

typedef uint16_t MMIndexType;

typedef struct
{
	matrix_float4x4 modelMatrix;
	matrix_float3x3 normalMatrix;
	matrix_float4x4 modelViewProjectionMatrix;
} MMUniforms;

typedef struct
{
	packed_float4 position;
	packed_float4 normal;    // Which way the 'front' is facing. Effects lighting and culling at least.
	packed_float2 texCoords; // Texture coordinates. (0,0) to (1, 1). This affects the 'origin' of your texture.
} MMVertices;
