//
//  Renderer.swift
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 5/23/15.
//  Copyright (c) 2015 Bradley Griffith. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

protocol RendererDelegate {
	func configureCommandBufferForRenderer(renderer: Renderer, commandBuffer: MTLCommandBuffer, drawable: CAMetalDrawable)
}

class Renderer: NSObject {
	
	var layer: CAMetalLayer!
	var device: MTLDevice!
	var commandQueue: MTLCommandQueue!
	
	var projectionMatrix: Matrix4!
	var worldMatrix: Matrix4!
	
	var cameraX: Float = 0.0
	var cameraY: Float = 0.0
	var cameraZ: Float = 1.0
	
	var delegate: RendererDelegate?
	var layerAspectRatio: Float = 1.0
	
	
	/* Lifecycle
	------------------------------------------*/
	
	init(metalLayer: CAMetalLayer) {
		super.init()
		
		layer = metalLayer
		
		_buildMetal()
		_setProjectionMatrix()
	}
	
	
	/* Private Instance Methods
	------------------------------------------*/
	
	private func _buildMetal() {
		layer.device =  MetalUtility.sharedInstance.device
		device = layer.device
		commandQueue = device.newCommandQueue()
	}
	
	private func _setProjectionMatrix() {
		let size: CGSize = layer.bounds.size
		layerAspectRatio = Float(size.width / size.height)
		let verticalFOV: Float = Float((layerAspectRatio > 1) ? (M_PI / 3) : (M_PI) / 2)
		let near: Float = 0.1;
		let far: Float = 100;
		
		projectionMatrix = Matrix4.makePerspectiveViewAngle(verticalFOV, aspectRatio:layerAspectRatio, nearZ:near, farZ:far)
	}
	
	private func _updateWorldMatrix() {
		worldMatrix = Matrix4.matrixFromTranslation(0, y: 0, z: -self.cameraZ)
	}
	
	
	/* Public Instance Methods
	------------------------------------------*/
	
	func draw() {
		let ratio: Float = Float(layer.bounds.size.width) / Float(layer.bounds.size.height)
		if (ratio != layerAspectRatio) {
			_setProjectionMatrix()
		}
		
		_updateWorldMatrix()
		
		let commandBuffer = commandQueue.commandBuffer()
		if let drawable = layer.nextDrawable() {
			
			if let configDelegate = delegate {
				configDelegate.configureCommandBufferForRenderer(self, commandBuffer: commandBuffer, drawable: drawable)
			}
			
			// Teardown and Commit
			commandBuffer.presentDrawable(drawable)
		}
		commandBuffer.commit()

	}
}