//
//  ViewController.swift
//  artest
//
//  Created by Nakano Yousuke on 2018/09/28.
//  Copyright © 2018年 Nakano Yousuke. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var text: UITextView!
    //AR Resourcesに目的の画像が埋め込まれている
    let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ARSCNViewDelegateを受け取れるようにする
        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //ARImageTrackingConfigurationに目的の画像を設定
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages!
        sceneView.session.run(configuration)
    }
    
    // ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor {
            // 目的の画像を青い面をかぶせる
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIColor.blue
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
        }
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let worldPosStr = "world position: (\(node.worldPosition.x.str2)m \(node.worldPosition.y.str2)m \(node.worldPosition.z.str2)m)"
        let rotStr = "rotation: (\(node.eulerAngles.x.rad2deg.str2)° \(node.eulerAngles.y.rad2deg.str2)° \(node.eulerAngles.z.rad2deg.str2)°)"
        let cameraPos = SCNVector3ToGLKVector3((sceneView.pointOfView?.worldPosition)!)
        let nodePos = SCNVector3ToGLKVector3(node.worldPosition)
        let distanceStr = "distance from camera: \(GLKVector3Distance(cameraPos, nodePos).str2)m"
        text.text = "\(worldPosStr)\n\(rotStr)\n\(distanceStr)"
    }
}

extension Float {
    var str2 : String {
        return String(format: "%.2f", self)
    }
    var rad2deg : Float {
        return self * 64.6972;
    }
}
