//
//  MetalUtility.swift
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 6/26/15.
//  Copyright © 2015 Bradley Griffith. All rights reserved.
//

import Foundation

class MetalUtility {
	let device: MTLDevice!
	let library: MTLLibrary!
	
	class var sharedInstance: MetalUtility {
		struct Static {
			static let instance: MetalUtility = MetalUtility()
		}
		return Static.instance
	}
	
	init() {
		// TODO: Not in love with the forced unwrapping here.
		self.device = MTLCreateSystemDefaultDevice()!
		self.library = device.newDefaultLibrary()!
	}
	
	func generateSamplerState(mipped isMipped: Bool, minMagLinear: Bool) -> MTLSamplerState {
		let descriptor: MTLSamplerDescriptor = MTLSamplerDescriptor()
		
		if isMipped {
			descriptor.mipFilter = MTLSamplerMipFilter.Linear
		}
		else {
			descriptor.mipFilter = MTLSamplerMipFilter.NotMipmapped
		}
		
		if minMagLinear {
			descriptor.minFilter = MTLSamplerMinMagFilter.Linear
			descriptor.magFilter = MTLSamplerMinMagFilter.Linear
		}
		else {
			descriptor.minFilter = MTLSamplerMinMagFilter.Nearest
			descriptor.magFilter = MTLSamplerMinMagFilter.Nearest
		}
		
		descriptor.maxAnisotropy         = 1
		descriptor.sAddressMode          = MTLSamplerAddressMode.ClampToEdge
		descriptor.tAddressMode          = MTLSamplerAddressMode.ClampToEdge
		descriptor.rAddressMode          = MTLSamplerAddressMode.ClampToEdge
		descriptor.normalizedCoordinates = true
		descriptor.lodMinClamp           = 0
		descriptor.lodMaxClamp           = FLT_MAX
		
		return device.newSamplerStateWithDescriptor(descriptor)
	}
}