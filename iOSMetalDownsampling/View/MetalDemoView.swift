//
//  MetalDemoView.swift
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 5/23/15.
//  Copyright (c) 2015 Bradley Griffith. All rights reserved.
//

import Foundation
import CoreMedia
import UIKit

struct GuassianSettings {
	var blurRadius: Int
	var width: Float
	var height: Float
}

class MetalDemoView: MetalView {
	
	let device: MTLDevice = MetalUtility.sharedInstance.device
	let imagePlane: Node = Plane()
	let samplerState: MTLSamplerState = MetalUtility.sharedInstance.generateSamplerState(mipped: true, minMagLinear: false)
	
	var compositePipeline: MTLRenderPipelineState!
	var depthTexture: MTLTexture!
	var depthState: MTLDepthStencilState!
	
	var baseZoomFactor: Float = 2
	var pinchZoomFactor: Float = 1
	
	var sampleLevel = 0
	
	var textureCache: TextureLevelCache!
	
	var downsampleEncoderCache: Dictionary<Int, Encoder> = Dictionary()

	var downsampleEncoderTest: Encoder?
	
	
	/* Lifecycle
	------------------------------------------*/
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		_setup()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		_setup()
	}
	
	private func _setup() {
		_createImagePlane()
		_buildDepthBuffer()
		_createPipelineStates()
		
		_setListeners()
	}
	
	
	/* Private Instance Methods
	------------------------------------------*/
	
	private func _createImagePlane() {
		let texture = METLTexture(resourceName: "input", ext: "jpg")
		texture.format = MTLPixelFormat.BGRA8Unorm
		texture.finalize(device, flip: false)
		imagePlane.texture = texture.texture
		textureCache = TextureLevelCache(texture: imagePlane.texture!, device: device)
		
		let sourceAspect: CGFloat = CGFloat(texture.texture.height) / CGFloat(texture.texture.width)
		imagePlane.scaleX = 1.0
		imagePlane.scaleY = Float(1.0 * sourceAspect)
	}
	
	private func _buildDepthBuffer() {
		let drawableSize = metalLayer.drawableSize
		let depthTextureDesc = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(MTLPixelFormat.Depth32Float, width:Int(drawableSize.width), height:Int(drawableSize.height), mipmapped:true)
		
		depthTexture = device.newTextureWithDescriptor(depthTextureDesc)
	}
	
	private func _createPipelineStates() {
		
		let library: MTLLibrary = MetalUtility.sharedInstance.library
		let compositeVert = library.newFunctionWithName("composite_vertex")
		let compositeFrag = library.newFunctionWithName("composite_fragment")
		
		let vertexDescriptor = MTLVertexDescriptor()
		vertexDescriptor.attributes[0].bufferIndex = 0
		vertexDescriptor.attributes[0].offset = 0
		vertexDescriptor.attributes[0].format = MTLVertexFormat.Float4
		vertexDescriptor.attributes[1].offset = 0
		vertexDescriptor.attributes[1].format = MTLVertexFormat.Float4
		vertexDescriptor.attributes[1].bufferIndex = 0
		vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunction.PerVertex
		vertexDescriptor.layouts[0].stepRate = 1
		vertexDescriptor.layouts[0].stride = sizeof(MMVertices)
		
		// Setup pipeline
		let pipelineDescriptor = MTLRenderPipelineDescriptor()
		pipelineDescriptor.label = "Composite"
		pipelineDescriptor.vertexFunction = compositeVert!
		pipelineDescriptor.vertexDescriptor = vertexDescriptor
		pipelineDescriptor.fragmentFunction = compositeFrag
		pipelineDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
		pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormat.Depth32Float;
		do {
			try compositePipeline = device.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
		} catch _ {
			// TODO: Do more here.
			print("Failed to create pipeline state")
		}
		
		let depthDescriptor: MTLDepthStencilDescriptor = MTLDepthStencilDescriptor()
		depthDescriptor.depthCompareFunction = MTLCompareFunction.Less;
		depthDescriptor.depthWriteEnabled = true;
		depthState = device.newDepthStencilStateWithDescriptor(depthDescriptor)
	}
	
	private func _setListeners() {
		let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchGesture:")
		self.addGestureRecognizer(pinchRecognizer)
	}
	
	private func _currentFrameBufferForDrawable(drawable: CAMetalDrawable) -> MTLRenderPassDescriptor {
		let currentFrameBuffer = MTLRenderPassDescriptor()
		
		currentFrameBuffer.colorAttachments[0].texture = drawable.texture
		currentFrameBuffer.colorAttachments[0].loadAction = MTLLoadAction.Clear
		currentFrameBuffer.colorAttachments[0].storeAction = MTLStoreAction.Store
		currentFrameBuffer.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1)
		
		currentFrameBuffer.depthAttachment.texture = depthTexture;
		currentFrameBuffer.depthAttachment.loadAction = MTLLoadAction.Clear;
		currentFrameBuffer.depthAttachment.storeAction = MTLStoreAction.DontCare;
		currentFrameBuffer.depthAttachment.clearDepth = 1;
		
		return currentFrameBuffer
	}
	
	private func _downsamplerForCurrentLevel() -> Encoder {
		var downsampler = downsampleEncoderCache[sampleLevel]
		if downsampler == nil {
			let outputDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(
				imagePlane.texture!.pixelFormat,
				width:Int(imagePlane.texture!.width),
				height:Int(imagePlane.texture!.height),
				mipmapped: false
			)
			do {
				try downsampler = downsampleEncoder(sampleLevel, textureDescriptor: outputDescriptor)
			} catch _ {
				print("Failed to create downsample encoder.")
			}
			downsampleEncoderCache[sampleLevel] = downsampler
		}
		return downsampler!
	}
	
	
	/* Public Instance Methods
	------------------------------------------*/
	
	func pinchGesture(gesture: UIPinchGestureRecognizer) {
		let scale: Float = Float(1.0 / gesture.scale)
		
		switch gesture.state
		{
		case UIGestureRecognizerState.Changed:
			pinchZoomFactor = scale
			break
		case UIGestureRecognizerState.Ended:
			baseZoomFactor = baseZoomFactor * pinchZoomFactor
			pinchZoomFactor = 1
		default:
			break
		}
		
		let constrainedZoom = fmaxf(1.0, fminf(100.0, baseZoomFactor * pinchZoomFactor))
		pinchZoomFactor = constrainedZoom / baseZoomFactor
	}
	
	override func gameloop(displayLink: CADisplayLink) {
		renderer.cameraZ = baseZoomFactor * pinchZoomFactor;
		
		super.gameloop(displayLink)
	}
	
	override func configureComputeEncoders(commandBuffer: MTLCommandBuffer, drawable: CAMetalDrawable) {
	}
	
	override func configureRenderEncoders(commandBuffer: MTLCommandBuffer, drawable: CAMetalDrawable) {
		dispatch_semaphore_wait(imagePlane.avaliableResourcesSemaphore, DISPATCH_TIME_FOREVER)
		
		let drawableSize = metalLayer.drawableSize
		if (depthTexture.width != Int(drawableSize.width) || depthTexture.height != Int(drawableSize.height)) {
			_buildDepthBuffer()
		}
		
		let downsampledTexture = _downsamplerForCurrentLevel()(commandBuffer, imagePlane.texture!)
		
		let uniformsBuffer = imagePlane.adjustUniformsForSceneUsingWorldMatrix(renderer.worldMatrix, projectionMatrix:renderer.projectionMatrix)
		
		let encoder = commandBuffer.renderCommandEncoderWithDescriptor(_currentFrameBufferForDrawable(drawable))
		
		encoder.pushDebugGroup("imagePlane render")
		encoder.setFrontFacingWinding(MTLWinding.CounterClockwise)
		encoder.setCullMode(MTLCullMode.None)
		encoder.setRenderPipelineState(compositePipeline)
		encoder.setDepthStencilState(depthState)
		encoder.setFragmentTexture(downsampledTexture, atIndex: 0)
		encoder.setFragmentSamplerState(samplerState, atIndex: 0)
		//encoder.setTriangleFillMode(MTLTriangleFillMode.Lines)
		encoder.setVertexBuffer(imagePlane.vertexBuffer, offset: 0, atIndex: 0)
		encoder.setVertexBuffer(uniformsBuffer, offset: 0, atIndex: 1)
		encoder.drawIndexedPrimitives(
			.Triangle,
			indexCount: imagePlane.indexBuffer.length / sizeof(MMIndexType),
			indexType: MTLIndexType.UInt16,
			indexBuffer: imagePlane.indexBuffer,
			indexBufferOffset: 0
		)
		
		encoder.popDebugGroup()
		encoder.endEncoding()
		
		commandBuffer.addCompletedHandler { (commandBuffer) -> Void in
			_ = dispatch_semaphore_signal(self.imagePlane.avaliableResourcesSemaphore)
		}
	}
	
	func setApproximateDetailLevel(approxLevel: Float) {
		sampleLevel = textureCache!.levelForNormalizedScale(approxLevel)
	}
}