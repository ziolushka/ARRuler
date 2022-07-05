//
//  ViewController.swift
//  AI 2022 AR Ruler
//
//  Created by Olena Zola on 04.07.2022.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeOldDotNodesIfNeeded()
        removeOldTextNodeIfNeeded()
        //We want to get current location of the receiver in the coordinate system (2D screen coordinates of point where user tapped)
        if let touchLocation = touches.first?.location(in: sceneView) {
            // ARKit creates a ray that extends in the positive z-direction from the argument screen space point, to determine if any of the argument targets exist in the physical environment anywhere along the ray.
            // That's the ray you create from a screen point you're interested in.
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .any) {
                // Ray casting provides a 3D location in physical space that corresponds to a given 2D location on the screen. An array of ray-cast results, sorted from nearest to furthest from the camera.
                if let result = sceneView.session.raycast(query).first {
                    addDotNode(at: result)
                }
            }
        }
    }
    
    func removeOldDotNodesIfNeeded() {
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
    }
    
    func removeOldTextNodeIfNeeded() {
        if textNode.parent != nil {
            textNode.removeFromParentNode()
        }
    }
    
    func addDotNode(at raycastResult : ARRaycastResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        dotGeometry.firstMaterial?.diffuse.contents = UIColor(named: "AccentColor")
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(raycastResult.worldTransform.columns.3.x,
                                      raycastResult.worldTransform.columns.3.y,
                                      raycastResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculateDistance()
        }
    }
    
    func calculateDistance() {
        if let start = dotNodes.first, let end = dotNodes.last {
            
            // Formula for calculeting distance between two points in 3D space
            // distance = √ ((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
            let distance = sqrt(pow(end.position.x - start.position.x, 2) +
                                pow(end.position.y - start.position.y, 2) +
                                pow(end.position.z - start.position.z, 2))
            
            addTextNode(text: String(format: "%.2f cm", abs(distance * 100)), atPosition: end.position)
        }
    }
    
    func addTextNode(text: String, atPosition position: SCNVector3){
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor(named: "AccentColor")
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.0025, 0.0025, 0.0025) //Scaled the text node to fit the screen of device
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
}
