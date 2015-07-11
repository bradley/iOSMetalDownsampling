//
//  EncoderHelpers.swift
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 7/10/15.
//  Copyright © 2015 Bradley Griffith. All rights reserved.
//

struct RenderPassColorAttachment {
	let texture: MTLTexture
	let loadAction: MTLLoadAction
	let clearColor: MTLClearColor
	let storeAction: MTLStoreAction
}

enum EncoderError: ErrorType {
	case FailedToCreatePipelineState
	case VertexFunctionNotFound
	case FragmentFunctionNotFound
}

typealias Encoder = (MTLCommandBuffer, MTLTexture) -> MTLTexture

infix operator >>> { associativity left }

func >>> (encoder1: Encoder, encoder2: Encoder) -> Encoder {
	return { (commandBuffer, texture) in encoder2(commandBuffer, encoder1(commandBuffer, texture)) }
}

func createRenderPassDescriptor(colorAttachments: [RenderPassColorAttachment]) -> MTLRenderPassDescriptor {
	let renderPassDescriptor: MTLRenderPassDescriptor = MTLRenderPassDescriptor()
	
	for (i, colorAttachment) in colorAttachments.enumerate() {
		renderPassDescriptor.colorAttachments[i].texture = colorAttachment.texture
		renderPassDescriptor.colorAttachments[i].loadAction = colorAttachment.loadAction
		renderPassDescriptor.colorAttachments[i].clearColor = colorAttachment.clearColor
		renderPassDescriptor.colorAttachments[i].storeAction = colorAttachment.storeAction
	}
	
	return renderPassDescriptor
}

func createPipelineState(
	vertexFunctionName vertexFunctionName: String,
	fragmentFunctionName: String,
	pixelFormats: [MTLPixelFormat],
	debugLabel: String) throws -> MTLRenderPipelineState {
		
		let library = MetalUtility.sharedInstance.library
		let vertexFunction = library.newFunctionWithName(vertexFunctionName)
		let fragmentFunction = library.newFunctionWithName(fragmentFunctionName)
		let pipelineDescriptor = MTLRenderPipelineDescriptor()
		
		if let vert = vertexFunction {
			pipelineDescriptor.vertexFunction = vert
		}
		else {
			throw EncoderError.VertexFunctionNotFound
		}
		
		if let frag = fragmentFunction {
			pipelineDescriptor.fragmentFunction = frag
		}
		else {
			throw EncoderError.FragmentFunctionNotFound
		}
		
		for (i, pixelFormat) in pixelFormats.enumerate() {
			pipelineDescriptor.colorAttachments[i].pixelFormat = pixelFormat
		}
		
		pipelineDescriptor.label = debugLabel
		
		let renderPipeline: MTLRenderPipelineState
		do {
			try renderPipeline = MetalUtility.sharedInstance.device.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
		} catch _ {
			print("Failed to create pipeline state")
			throw EncoderError.FailedToCreatePipelineState
		}
		
		return renderPipeline
}