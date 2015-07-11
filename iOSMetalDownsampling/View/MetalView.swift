//
//  MetalView.swift
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 5/23/15.
//  Copyright (c) 2015 Bradley Griffith. All rights reserved.
//

import Foundation
import CoreMedia
import Metal
import UIKit

class MetalView: UIView, RendererDelegate {
	
	var renderer: Renderer! = nil
	var timer: CADisplayLink = CADisplayLink()
	var metalLayer: CAMetalLayer {
		get {
			return self.layer as! CAMetalLayer
		}
	}
	
	
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
	
	override class func layerClass() -> AnyClass {
		return CAMetalLayer.self
	}
	
	
	/* Private Instance Methods
	------------------------------------------*/
	
	private func _setup() {
		_setFrame()
		_setupRenderer()
		_createDisplayLink()
	}
	
	private func _setFrame() {
		backgroundColor = UIColor.blueColor()
		
		// During the first layout pass, we will not be in a view hierarchy, so we guess our scale
		var scale: CGFloat = UIScreen.mainScreen().scale
		
		// If we've moved to a window by the time our frame is being set, we can take its scale as our own
		if (window != nil) {
			scale = window!.screen.scale
		}
		
		var drawableSize: CGSize = bounds.size
		
		// Since drawable size is in pixels, we need to multiply by the scale to move from points to pixels
		drawableSize.width *= scale
		drawableSize.height *= scale
		
		metalLayer.drawableSize = drawableSize
	}
	
	private func _setupRenderer() {
		renderer = Renderer(metalLayer: metalLayer)
		renderer.delegate = self
	}
	
	private func _createDisplayLink() {
		timer = CADisplayLink(target: self, selector: Selector("gameloop:"))
	}
	
	private func _render() {
		renderer.draw()
	}
	
	
	/* Public Instance Methods
	------------------------------------------*/
	
	func start() {
		timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
	}
	
	func stop() {
		timer.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
	}
	
	func gameloop(displayLink: CADisplayLink) {
		autoreleasepool {
			self._render()
		}
	}
	
	func configureComputeEncoders(commandBuffer: MTLCommandBuffer, drawable: CAMetalDrawable) {
		// Abstract. Override in subclass.
	}
	
	func configureRenderEncoders(commandBuffer: MTLCommandBuffer, drawable: CAMetalDrawable) {
		// Abstract. Override in subclass.
	}
	
	
	/* Renderer Delegate Methods
	------------------------------------------*/
	
	func configureCommandBufferForRenderer(renderer: Renderer, commandBuffer: MTLCommandBuffer, drawable: CAMetalDrawable) {
		configureComputeEncoders(commandBuffer, drawable: drawable)
		configureRenderEncoders(commandBuffer, drawable: drawable)
	}

}