//
//  ViewController.swift
//  cARd
//
//  Created by Artem Novichkov on 03/08/2017.
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var planes = [OverlayPlane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.delegate = self
        
        addCardNode()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        sceneView.addGestureRecognizer(recognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    fileprivate func addCardNode() {
        let plane = SCNPlane(width: 0.12065, height: 0.085725)
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = UIImage(named: "201407150120_OB_A81_FRONT")
        plane.materials = [material]
        
        let cardNode = SCNNode(geometry: plane)
        cardNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: plane, options: nil))
        cardNode.position = SCNVector3(0, 0, -0.5)
        
        sceneView.scene.rootNode.addChildNode(cardNode)
    }
    
    @objc func tap(recognizer: UIGestureRecognizer) {
        let touchLocation = recognizer.location(in: sceneView)
        let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        guard let result = results.first else {
            return
        }
        addCard(with: result)
    }
    
    func addCard(with result: ARHitTestResult) {
        let plane = SCNPlane(width: 0.1016, height: 0.0762)
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = UIImage(named: "201407150120_OB_A81_FRONT")
        plane.materials = [material]
        
        let cardNode = SCNNode(geometry: plane)
        cardNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: plane, options: nil))
        cardNode.position = SCNVector3(result.worldTransform.columns.3.x,
                                       result.worldTransform.columns.3.y,
                                       result.worldTransform.columns.3.z)
        cardNode.rotation = planes.first!.rotation
        cardNode.eulerAngles = SCNVector3Make(-1.5708, 0, 0)
        
        sceneView.scene.rootNode.addChildNode(cardNode)
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        let plane = OverlayPlane(anchor: planeAnchor)
        planes.append(plane)
        print("START")
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        let plane = self.planes.filter { $0.anchor.identifier == anchor.identifier }.first
        
        if plane == nil {
            return
        }
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
}
