//
//  Basic.swift
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 6/23/15.
//  Copyright © 2015 Bradley Griffith. All rights reserved.
//

func basicEncoder(textureDescriptor: MTLTextureDescriptor) throws -> Encoder {
	
	let renderPlane: Plane = Plane()
	let samplerState = MetalUtility.sharedInstance.generateSamplerState(mipped: false, minMagLinear: false)
	let outTexture: MTLTexture = MetalUtility.sharedInstance.device.newTextureWithDescriptor(textureDescriptor)
	let renderPipeline: MTLRenderPipelineState
	try renderPipeline = createPipelineState(
		vertexFunctionName: "basic_vertex",
		fragmentFunctionName: "basic_fragment",
		pixelFormats: [textureDescriptor.pixelFormat],
		debugLabel: "basic"
	)
	
	let renderPassDescriptor: MTLRenderPassDescriptor = createRenderPassDescriptor([
		RenderPassColorAttachment(
			texture: outTexture,
			loadAction: MTLLoadAction.Load,
			clearColor: MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1.0),
			storeAction: MTLStoreAction.Store)
		]
	)

	return { commandBuffer, inTexture in
		let encoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
		
		encoder.pushDebugGroup("Basic render")
		encoder.setCullMode(MTLCullMode.None)
		encoder.setRenderPipelineState(renderPipeline)
		encoder.setVertexBuffer(renderPlane.vertexBuffer, offset: 0, atIndex: 0)
		encoder.setFragmentTexture(inTexture, atIndex: 0)
		encoder.setFragmentSamplerState(samplerState, atIndex: 0)
		
		encoder.drawIndexedPrimitives(
			.Triangle,
			indexCount: renderPlane.indexBuffer.length / sizeof(MMIndexType),
			indexType: MTLIndexType.UInt16,
			indexBuffer: renderPlane.indexBuffer,
			indexBufferOffset: 0
		)
		
		encoder.popDebugGroup()
		encoder.endEncoding()
		
		return outTexture
	}
}
