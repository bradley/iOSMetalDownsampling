//
//  Node.swift
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 5/23/15.
//  Copyright (c) 2015 Bradley Griffith. All rights reserved.
//

import UIKit
import Metal
import QuartzCore
import GLKit.GLKMath

class Node: NSObject {
 
	var name: String!
	var texture: MTLTexture?
	
	var vertexBuffer: MTLBuffer!
	var indexBuffer: MTLBuffer!
	
	let inflightBuffersCount: Int = 3
	private var uniformsBuffers: [MTLBuffer]!
	private var avaliableBufferIndex: Int = 0
	var avaliableResourcesSemaphore: dispatch_semaphore_t!
	
	var device: MTLDevice!
	
	var positionX: Float = 0.0
	var positionY: Float = 0.0
	var positionZ: Float = 0.0
 
	var rotationX: Float = 0.0
	var rotationY: Float = 0.0
	var rotationZ: Float = 0.0
	
	var scaleX: Float    = 1.0
	var scaleY: Float    = 1.0
	var scaleZ: Float    = 1.0
	
	
	/* Lifecycle
	------------------------------------------*/
	
	init(givenName: String, vertices: Array<Float>, indices: Array<Int16>){
		super.init()
		
		avaliableResourcesSemaphore = dispatch_semaphore_create(inflightBuffersCount)
		
		name = givenName
		device = MetalUtility.sharedInstance.device
		
		vertexBuffer = device.newBufferWithBytes(vertices, length: vertices.count * sizeofValue(vertices[0]), options: MTLResourceOptions.OptionCPUCacheModeDefault)
		indexBuffer = device.newBufferWithBytes(indices, length: indices.count * sizeofValue(indices[0]), options: MTLResourceOptions.OptionCPUCacheModeDefault)
		
		self._createBufferPool()
	}
	
	deinit{
		for _ in 0...self.inflightBuffersCount{
			dispatch_semaphore_signal(self.avaliableResourcesSemaphore)
		}
	}
	
	
	/* Private Instance Methods
	------------------------------------------*/
	
	private func _createBufferPool() {
		uniformsBuffers = [MTLBuffer]()
		
		for _ in 0...inflightBuffersCount - 1 {
			let uniformsBuffer = device.newBufferWithLength(sizeof(MMUniforms), options: MTLResourceOptions.OptionCPUCacheModeDefault)
			uniformsBuffers.append(uniformsBuffer)
		}
	}
	
	private func _nextUniformsBuffer() -> MTLBuffer {
		let buffer = uniformsBuffers[avaliableBufferIndex]
		
		avaliableBufferIndex++
		
		if (avaliableBufferIndex == inflightBuffersCount) {
			avaliableBufferIndex = 0
		}
		
		return buffer
	}
	
	
	/* Public Instance Methods
	------------------------------------------*/
	
	func adjustUniformsForSceneUsingWorldMatrix(worldModelMatrix: Matrix4, projectionMatrix: Matrix4) -> MTLBuffer {
		let uniformsBuffer = _nextUniformsBuffer()
		
		let xRotation: Matrix4 = Matrix4.matrixFromAxisRotation(1, y:0, z:0, angle:self.rotationX)
		let yRotation: Matrix4 = Matrix4.matrixFromAxisRotation(0, y:1, z:0, angle:self.rotationY)
		let zRotation: Matrix4 = Matrix4.matrixFromAxisRotation(0, y:0, z:1, angle:self.rotationZ)
		let rotation: Matrix4 = Matrix4.multiplyMatrix(xRotation, byMatrix: Matrix4.multiplyMatrix(yRotation, byMatrix: zRotation))
		let translation: Matrix4 = Matrix4.matrixFromTranslation(positionX, y:positionY, z:positionZ)
		let cubeModelMatrix: Matrix4 = Matrix4.scaleMatrix(Matrix4.multiplyMatrix(translation, byMatrix: rotation), x: scaleX, y: scaleY, z: scaleZ)
		
		var uniforms: MMUniforms = MMUniforms(
			modelMatrix: cubeModelMatrix.cMatrix(),
			normalMatrix: Matrix3.transposeMatrix(Matrix3.invertMatrix(Matrix4.getMatrix3ForMatrix(cubeModelMatrix))).cMatrix(),
			modelViewProjectionMatrix: Matrix4.multiplyMatrix(projectionMatrix, byMatrix: Matrix4.multiplyMatrix(worldModelMatrix, byMatrix:cubeModelMatrix)).cMatrix()
		)
		
		memcpy((uniformsBuffer.contents()), &uniforms, sizeof(MMUniforms))
		
		return uniformsBuffer
	}
}