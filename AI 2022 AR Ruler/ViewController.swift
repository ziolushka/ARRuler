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
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .any) {
                
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
    
    func addDotNode(at hitResult : ARRaycastResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        dotGeometry.firstMaterial?.diffuse.contents = UIColor(named: "AccentColor")
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                      hitResult.worldTransform.columns.3.y,
                                      hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculateDistance()
        }
    }
    
    func calculateDistance() {
        if let start = dotNodes.first, let end = dotNodes.last {
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
        textNode.scale = SCNVector3(0.0025, 0.0025, 0.0025)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
}
