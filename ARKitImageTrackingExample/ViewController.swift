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
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var button: UIButton!
    
    //AR Resourcesに目的の画像が埋め込まれている
    let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // buttonのイベント
        button.addTarget(self, action: #selector(self.tapButton), for: .touchDown)
        //ARSCNViewDelegateを受け取れるようにする
        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //ARWorldTrackingConfigurationに目的の画像を設定
        //let configuration = ARWorldTrackingConfiguration()
        //configuration.detectionImages = referenceImages!
        //sceneView.debugOptions = .showFeaturePoints
        //ARImageTrackingConfigurationに目的の画像を設定
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages!
        sceneView.session.run(configuration)
    }
    
    // ARSCNViewDelegate
    var arNode = SCNNode()
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if let imageAnchor = anchor as? ARImageAnchor {
            // 目的の画像を青い面をかぶせる
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.85)
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            arNode.addChildNode(planeNode)
        }
        return arNode
    }
    
    var currentPos: SCNVector3?
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let nPos = node.worldPosition // position of node releated by camera(iPhone)
        let nRot = node.eulerAngles
        let cPos = (sceneView.pointOfView?.worldPosition)! // position of camera(iPhone) = (0,0,0)
        let worldPosStr = "node position: (\(nPos.x.prec2)m \(nPos.y.prec2)m \(nPos.z.prec2)m)"
        let rotStr = "rotation: (\(nRot.x.rad2deg.prec2)° \(nRot.y.rad2deg.prec2)° \(nRot.z.rad2deg.prec2)°)"
        let cameraPosStr = "camera position: (\(cPos.x.prec2)m \(cPos.y.prec2)m \(cPos.z.prec2)m)"
        let distanceStr = "distance from camera: \(calcScenePositionDistance(cPos, nPos).prec2)m"
        text.text = "\(worldPosStr)\n\(rotStr)\n\(cameraPosStr)\n\(distanceStr))"
        currentPos = nPos
    }
    
    var firstPos: SCNVector3?
    var secondPos: SCNVector3?
    @objc private func tapButton() {
        if (currentPos != nil) {
            if (firstPos == nil) {
                firstPos = currentPos
                button.setTitle("Set Destination", for: .normal)
            } else if (secondPos == nil) {
                secondPos = currentPos
                let dist = calcScenePositionDistance(firstPos!, secondPos!)
                button.setTitle("moved \(dist)m", for: .normal)
            } else {
                firstPos = nil
                secondPos = nil
                button.setTitle("Set Start Position", for: .normal)
            }
        }
    }
    
    private func calcScenePositionDistance(_ posA: SCNVector3, _ posB: SCNVector3) -> Float {
        return GLKVector3Distance(SCNVector3ToGLKVector3(posA), SCNVector3ToGLKVector3(posB))
    }
}

extension Float {
    var prec2 : String {
        return String(format: "%.2f", self)
    }
    var rad2deg : Float {
        return self * 64.6972;
    }
}
