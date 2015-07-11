//
//  TextureUtility.swift
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 5/23/15.
//  Copyright (c) 2015 Bradley Griffith. All rights reserved.
//

import CoreMedia
import Metal

class TextureUtility: NSObject {
	
	var device: MTLDevice!
	var texture: MTLTexture! {
		didSet {
			self._setDescriptorForTexture()
		}
	}
	private var size: MTLSize = MTLSizeMake(0, 0, 0)
	private var origin: MTLOrigin = MTLOriginMake(0, 0, 0)
	private var descriptor: MTLTextureDescriptor?
	private var copyTexture: MTLTexture!
	
	
	init(texture: MTLTexture, device: MTLDevice) {
		super.init()
		
		self.texture = texture
		self.device = device
		
		self._setDescriptorForTexture();
	}
	
	
	class func generateMipmapsAcceleratedFromTexture(texture: MTLTexture, device: MTLDevice, completionBlock:(newTexture: MTLTexture) -> Void) {
		// Note: This function should be used when you do not have an existing MTLCommandBuffer object and it is fine to create
		//   and commit a new one. If you have an existing MTLCommandBuffer object when you need to create a new mipmap pyramid, you should use
		//   generateMipmapsFromTexture(texture: MTLTexture, device: MTLDevice, commandBuffer: MTLCommandBuffer, completionBlock:(newTexture: MTLTexture)
		
		
		// Note: From Apple developer Frogblast explaining why the generation of a new texture is necessary here:
		//   CVPixelBuffer images typically have a linear/stride layout, as non-GPU hardware blocks might be interacting with those, and most GPU hardware only supports mipmapping from tiled textures.
		//   You'll need to issue a blit to copy from the linear MTLTexture to a private MTLTexture of your own creation, then generate mipmaps.
		
		let commandQueue = device.newCommandQueue()
		let commandBuffer = commandQueue.commandBuffer()
		let commandEncoder = commandBuffer.blitCommandEncoder()
		
		let origin = MTLOriginMake(0, 0, 0)
		let size = MTLSizeMake(texture.width, texture.height, texture.depth)
		let format = texture.pixelFormat
		let desc = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(format, width: Int(texture.width), height: Int(texture.height), mipmapped: true)
		let tempTexture = device.newTextureWithDescriptor(desc)
		
		// Copy from texture to temporary texture.
		commandEncoder.copyFromTexture(texture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: origin, sourceSize: size, toTexture: tempTexture, destinationSlice: 0, destinationLevel: 0, destinationOrigin: origin)
		
		commandEncoder.generateMipmapsForTexture(tempTexture)
		
		commandEncoder.endEncoding()
		
		commandBuffer.addCompletedHandler({ (MTLCommandBuffer) -> Void in
			completionBlock(newTexture: tempTexture)
		})
		
		commandBuffer.commit()
	}
	
	class func generateMipmapsFromTexture(texture: MTLTexture, device: MTLDevice, commandBuffer: MTLCommandBuffer, completionBlock:(newTexture: MTLTexture) -> Void) {
		// Note: From Apple developer Frogblast explaining why the generation of a new texture is necessary here:
		//   CVPixelBuffer images typically have a linear/stride layout, as non-GPU hardware blocks might be interacting with those, and most GPU hardware only supports mipmapping from tiled textures.
		//   You'll need to issue a blit to copy from the linear MTLTexture to a private MTLTexture of your own creation, then generate mipmaps.
		
		let commandEncoder = commandBuffer.blitCommandEncoder()
		
		let origin = MTLOriginMake(0, 0, 0)
		let size = MTLSizeMake(texture.width, texture.height, texture.depth)
		let format = texture.pixelFormat
		let desc = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(format, width: Int(texture.width), height: Int(texture.height), mipmapped: true)
		let tempTexture = device.newTextureWithDescriptor(desc)
		
		// Copy from texture to temporary texture.
		commandEncoder.copyFromTexture(texture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: origin, sourceSize: size, toTexture: tempTexture, destinationSlice: 0, destinationLevel: 0, destinationOrigin: origin)
		
		commandEncoder.generateMipmapsForTexture(tempTexture)
		
		commandEncoder.endEncoding()
		
		commandBuffer.addCompletedHandler({ (MTLCommandBuffer) -> Void in
			completionBlock(newTexture: tempTexture)
		})
	}
	
	
	private func _setDescriptorForTexture() {
		if (descriptor == nil || texture.width != size.width || texture.height != size.height) {
			let format = texture.pixelFormat
			size = MTLSizeMake(texture.width, texture.height, texture.depth)
			descriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(format, width: Int(texture.width), height: Int(texture.height), mipmapped: true)
			copyTexture = device.newTextureWithDescriptor(descriptor!)
		}
	}
	
	func generateMipmapsAccelerated(completionBlock:(newTexture: MTLTexture) -> Void) {
		let commandQueue = device.newCommandQueue()
		let commandBuffer = commandQueue.commandBuffer()
		let commandEncoder = commandBuffer.blitCommandEncoder()
		
		// Copy from texture to temporary texture.
		commandEncoder.copyFromTexture(texture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: origin, sourceSize: size, toTexture: copyTexture, destinationSlice: 0, destinationLevel: 0, destinationOrigin: origin)
		
		commandEncoder.generateMipmapsForTexture(copyTexture)
		
		commandEncoder.endEncoding()
		
		commandBuffer.addCompletedHandler({ (MTLCommandBuffer) -> Void in
			completionBlock(newTexture: self.copyTexture)
		})
		
		commandBuffer.commit()
	}
	
	
	func generateMipmaps(commandBuffer: MTLCommandBuffer, completionBlock:(newTexture: MTLTexture) -> Void) {
		let commandEncoder = commandBuffer.blitCommandEncoder()
		
		// Copy from texture to temporary texture.
		commandEncoder.copyFromTexture(texture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: origin, sourceSize: size, toTexture: copyTexture, destinationSlice: 0, destinationLevel: 0, destinationOrigin: origin)
		
		commandEncoder.generateMipmapsForTexture(copyTexture)
		
		commandEncoder.endEncoding()
		
		commandBuffer.addCompletedHandler({ (MTLCommandBuffer) -> Void in
			completionBlock(newTexture: self.copyTexture)
		})
	}
	
}