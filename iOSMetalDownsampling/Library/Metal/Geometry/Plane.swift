//
//  Plane.swift
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 5/24/15.
//  Copyright (c) 2015 Bradley Griffith. All rights reserved.
//

import UIKit

class Plane: Node {
	init() {
		
		let vertices:Array<Float> = [
			-1.0, -1.0, 0.0, 1.0,    0.0, 0.0, 1.0, 0.0,    0.0, 1.0,
			 1.0, -1.0, 0.0, 1.0,    0.0, 0.0, 1.0, 0.0,    1.0, 1.0,
			 1.0,  1.0, 0.0, 1.0,    0.0, 0.0, 1.0, 0.0,    1.0, 0.0,
			-1.0,  1.0, 0.0, 1.0,    0.0, 0.0, 1.0, 0.0,    0.0, 0.0
		]
		
		/*
			0...1
			.  ..
			. . .
		   ..  .
			3...2
		*/
		
		let indices:Array<Int16> = [
			0, 1, 3, 3, 1, 2
		]
		
		super.init(givenName: "Plane", vertices: vertices, indices: indices)
		
	}
}