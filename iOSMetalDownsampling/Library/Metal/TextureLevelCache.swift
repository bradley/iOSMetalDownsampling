//
//  TextureLevelCache.swift
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 5/24/15.
//  Copyright (c) 2015 Bradley Griffith. All rights reserved.
//

import Foundation

class TextureLevelCache: NSObject {
	
	var textureCache: [MTLTexture]?
	var device: MTLDevice!
	var texture: MTLTexture! {
		didSet {
			self._updateTextureCache()
		}
	}
	var totalLevels: Int {
		get {
			return Int(floor(log2(Float(max(max(self.texture.width, self.texture.height), self.texture.depth)))) + 1)
		}
	}
	
	private var previousSize: CGSize = CGSizeMake(0.0, 0.0)
	
	
	init(texture: MTLTexture, device: MTLDevice) {
		self.texture = texture
		self.device = device
		super.init()
		self._updateTextureCache()
	}
	
	func textureAtLevel(level: Int) -> MTLTexture? {
		var returnTexture: MTLTexture?
		if let texture = textureCache?[level] {
			returnTexture = texture
		}
		return textureCache?[level]
	}
	
	func levelForNormalizedScale(scale: Float) -> Int {
		let adjustedScale = min(1, scale)
		return Int(round(adjustedScale * Float(totalLevels - 1)))
	}
	
	private func _updateTextureCache() {
		if (self.texture.height == Int(previousSize.height) && self.texture.width == Int(previousSize.width)) {
			return
		}
		
		self._updateSize()
		textureCache = []
		let format = MTLPixelFormat.BGRA8Unorm
		
		for var index = 0; index < totalLevels; ++index {
			let scaledWidth = self._scaled(self.texture.width, forLevel:index)
			let scaledHeight = self._scaled(self.texture.height, forLevel:index)
			let desc = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(format, width: Int(scaledWidth), height: Int(scaledHeight), mipmapped: false)
			let texture = device.newTextureWithDescriptor(desc)
			
			textureCache?.append(texture)
		}
	}
	
	private func _updateSize() {
		previousSize.width = CGFloat(texture.width)
		previousSize.height = CGFloat(texture.height)
	}
	
	private func _scaled(size: Int, forLevel: Int) -> Float {
		return max(1, floor(Float(size) / pow(2, Float(forLevel))))
	}
}