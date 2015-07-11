//
//  MetalViewController.swift
//  iOSMetalDownsampling
//
//  Created by Bradley Griffith on 5/23/15.
//  Copyright (c) 2015 Bradley Griffith. All rights reserved.
//

import UIKit
import CoreMedia

class MetalViewController: UIViewController {

	var metalDemoView: MetalDemoView {
		get {
			// NOTE: In the current setup, the view needs to also be set
			//   as an object of MirrorSceneView from interface builder!
			return self.view as! MetalDemoView
		}
	}
	@IBOutlet weak var detailLevelSlider: UISlider!
	
	
	/* Lifecycle
	------------------------------------------*/
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		metalDemoView.start()
	}
	

	@IBAction func setDetailLevel(sender: AnyObject) {
		metalDemoView.setApproximateDetailLevel(detailLevelSlider.value)
	}
}