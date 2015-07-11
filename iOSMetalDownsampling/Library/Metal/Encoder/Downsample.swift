//
//  Downsample.swift
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 7/10/15.
//  Copyright © 2015 Bradley Griffith. All rights reserved.
//

func downsampleEncoder(level: Int, textureDescriptor: MTLTextureDescriptor) throws -> Encoder {
	let outTexture: MTLTexture = MetalUtility.sharedInstance.device.newTextureWithDescriptor(textureDescriptor)
	
	let textureCache = TextureLevelCache(texture: outTexture, device: MetalUtility.sharedInstance.device)
	let downsampleLevel = level <= textureCache.totalLevels - 1 ? level : textureCache.totalLevels - 1
	let texture = textureCache.textureAtLevel(downsampleLevel)
	let downsampleDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(textureDescriptor.pixelFormat, width: (texture?.width)!, height: (texture?.height)!, mipmapped: false)
	
	let blurRadius: Int = Int(pow(Double(downsampleLevel), 2.0))
	
	let composite: Encoder
	try composite = boxBlurEncoder(blurRadius, textureDescriptor: textureDescriptor) >>> basicEncoder(downsampleDescriptor)
	
	return { commandBuffer, inTexture in
		return composite(commandBuffer, inTexture)
	}
}