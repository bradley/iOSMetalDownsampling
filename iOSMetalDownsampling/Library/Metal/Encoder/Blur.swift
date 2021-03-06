//
//  Blur.swift
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 7/10/15.
//  Copyright © 2015 Bradley Griffith. All rights reserved.
//

func horizontalBoxBlurEncoder(textureDescriptor: MTLTextureDescriptor, settingsBuffer: MTLBuffer) throws -> Encoder {
	
	let renderPlane = Plane()
	let samplerState = MetalUtility.sharedInstance.generateSamplerState(mipped: false, minMagLinear: false)
	let outTexture: MTLTexture = MetalUtility.sharedInstance.device.newTextureWithDescriptor(textureDescriptor)
	let renderPipeline: MTLRenderPipelineState
	try renderPipeline = createPipelineState(
		vertexFunctionName: "basic_vertex",
		fragmentFunctionName: "horizontal_box_blur_fragment",
		pixelFormats: [textureDescriptor.pixelFormat],
		debugLabel: "horizontal blur"
	)
	
	let renderPassDescriptor: MTLRenderPassDescriptor = createRenderPassDescriptor([
		RenderPassColorAttachment(
			texture: outTexture,
			loadAction: MTLLoadAction.Load,
			clearColor: MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1.0),
			storeAction: MTLStoreAction.Store)
		])
	
	return { commandBuffer, inTexture in
		let encoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
		
		encoder.pushDebugGroup("Horizontal box blur render")
		encoder.setCullMode(MTLCullMode.None)
		encoder.setRenderPipelineState(renderPipeline)
		encoder.setVertexBuffer(renderPlane.vertexBuffer, offset: 0, atIndex: 0)
		encoder.setFragmentTexture(inTexture, atIndex: 0)
		encoder.setFragmentSamplerState(samplerState, atIndex: 0)
		encoder.setFragmentBuffer(settingsBuffer, offset: 0, atIndex: 0)
		
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

func verticalBoxBlurEncoder(textureDescriptor: MTLTextureDescriptor, settingsBuffer: MTLBuffer) throws -> Encoder {
	
	let renderPlane = Plane()
	let samplerState = MetalUtility.sharedInstance.generateSamplerState(mipped: false, minMagLinear: false)
	let outTexture: MTLTexture = MetalUtility.sharedInstance.device.newTextureWithDescriptor(textureDescriptor)
	let renderPipeline: MTLRenderPipelineState
	try renderPipeline = createPipelineState(
		vertexFunctionName: "basic_vertex",
		fragmentFunctionName: "vertical_box_blur_fragment",
		pixelFormats: [textureDescriptor.pixelFormat],
		debugLabel: "vertical blur"
	)
	
	let renderPassDescriptor: MTLRenderPassDescriptor = createRenderPassDescriptor([
		RenderPassColorAttachment(
			texture: outTexture,
			loadAction: MTLLoadAction.Load,
			clearColor: MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1.0),
			storeAction: MTLStoreAction.Store)
		])
	
	return { commandBuffer, inTexture in
		let encoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
		
		encoder.pushDebugGroup("Vertical box blur render")
		encoder.setCullMode(MTLCullMode.None)
		encoder.setRenderPipelineState(renderPipeline)
		encoder.setVertexBuffer(renderPlane.vertexBuffer, offset: 0, atIndex: 0)
		encoder.setFragmentTexture(inTexture, atIndex: 0)
		encoder.setFragmentSamplerState(samplerState, atIndex: 0)
		encoder.setFragmentBuffer(settingsBuffer, offset: 0, atIndex: 0)
		
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

func boxBlurEncoder(var radius: Int, textureDescriptor: MTLTextureDescriptor) throws -> Encoder {
	let composite: Encoder
	let downsampleDataBuffer = MetalUtility.sharedInstance.device.newBufferWithBytes(&radius, length: sizeof(Int), options: MTLResourceOptions.OptionCPUCacheModeDefault)
	
	try composite = horizontalBoxBlurEncoder(textureDescriptor, settingsBuffer: downsampleDataBuffer) >>> verticalBoxBlurEncoder(textureDescriptor, settingsBuffer: downsampleDataBuffer)
	
	return { commandBuffer, inTexture in
		return composite(commandBuffer, inTexture)
	}
}