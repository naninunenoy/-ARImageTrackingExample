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
    var firstPos: SCNVector3?
    var currentPos: SCNVector3?
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
            plane.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.85)
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
        }
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let nPos = node.worldPosition // world position of node
        let nRot = node.eulerAngles // world position of camera(iPhone)
        let cPos = sceneView.pointOfView?.worldPosition
        nodePositionUpdate(pos: nPos)
        let worldPosStr = "world position: (\(nPos.x.prec2)m \(nPos.y.prec2)m \(nPos.z.prec2)m)"
        let rotStr = "rotation: (\(nRot.x.rad2deg.prec2)° \(nRot.y.rad2deg.prec2)° \(nRot.z.rad2deg.prec2)°)"
        let distanceStr = "distance from camera: \(calcScenePositionDistance(cPos!, nPos).prec2)m"
        let moveLenStr = "moved distance: \(calcScenePositionDistance(cPos!, nPos).prec2)m"
        text.text = "\(worldPosStr)\n\(rotStr)\n\(distanceStr)\n\(moveLenStr)"
    }
    
    private func nodePositionUpdate(pos: SCNVector3) {
        if (currentPos == nil) {
            firstPos = pos
            currentPos = pos
        } else {
            // 一定以上の動きで更新
            let moveLen = calcScenePositionDistance(currentPos!, pos)
            if (moveLen > 0.02) {
                currentPos = pos
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
