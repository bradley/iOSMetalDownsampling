//
//  Downsample.metal
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 5/23/15.
//  Copyright (c) 2015 Bradley Griffith. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut
{
	float4 position [[position]];
	float3 normal [[user(normal)]];
	float2 texCoords [[user(tex_coords)]];
};

struct DownsampleSettings {
	int sampleLevel;
};


/* Fragment Shaders
	------------------------------------------*/

fragment float4 horizontal_box_blur_fragment(VertexOut                        vert      [[ stage_in ]],
															texture2d<float, access::sample> texture   [[ texture(0) ]],
															sampler                          sampler2D [[ sampler(0) ]],
															const device DownsampleSettings* settings  [[ buffer(0) ]])
{
	int blurRadius = pow(settings->sampleLevel, 2.0f);
	int blurArea = (2 * blurRadius + 1);
	
	float4 outColor = float4(0.0);
	for (int i = -blurRadius; i <= blurRadius; i++)
	{
		float4 inColor = texture.sample(sampler2D, vert.texCoords, int2(0 + i, 0));
		outColor += inColor;
	}
	outColor /= blurArea;
	return outColor;
}

fragment float4 vertical_box_blur_fragment(VertexOut                        vert      [[ stage_in ]],
														 texture2d<float, access::sample> texture   [[ texture(0) ]],
														 sampler                          sampler2D [[ sampler(0) ]],
														 const device DownsampleSettings* settings  [[ buffer(0) ]])
{
	int blurRadius = pow(settings->sampleLevel, 2.0f);
	int blurArea = (2 * blurRadius + 1);
	
	float4 outColor = float4(0.0);
	for (int i = -blurRadius; i <= blurRadius; i++)
	{
		float4 inColor = texture.sample(sampler2D, vert.texCoords, int2(0, 0 + i));
		outColor += inColor;
	}
	outColor /= blurArea;
	return outColor;
}
