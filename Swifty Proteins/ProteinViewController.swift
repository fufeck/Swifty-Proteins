//
//  ProteinViewController.swift
//  Swifty Proteins
//
//  Created by Fabien TAFFOREAU on 10/21/16.
//  Copyright © 2016 Fabien TAFFOREAU. All rights reserved.
//

import UIKit
import SceneKit

class   CylinderLine: SCNNode
{
    init( parent: SCNNode, v1: SCNVector3, v2: SCNVector3) {
        super.init()
        let  height = v1.distance(v2)
        position = v1
        let nodeV2 = SCNNode()
        nodeV2.position = v2
        parent.addChildNode(nodeV2)
        let zAlign = SCNNode()
        zAlign.eulerAngles.x = Float(M_PI_2)
        let cyl = SCNCylinder(radius: 0.1, height: CGFloat(height))
        cyl.firstMaterial?.diffuse.contents = UIColor.grayColor()
        let nodeCyl = SCNNode(geometry: cyl)
        nodeCyl.position.y = Float(-height/2)
        zAlign.addChildNode(nodeCyl)
        addChildNode(zAlign)
        constraints = [SCNLookAtConstraint(target: nodeV2)]
    }
    
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

private extension SCNVector3{
    func distance(receiver:SCNVector3) -> Double {
        let xd = receiver.x - self.x
        let yd = receiver.y - self.y
        let zd = receiver.z - self.z
        let distance = Double(sqrt(xd * xd + yd * yd + zd * zd))
        
        if (distance < 0) {
            return (distance * -1)
        }
        return (distance)
    }
}


class ProteinViewController: UIViewController, SCNSceneRendererDelegate {

    var ligand : Ligand?
    // Geometry
    var geometryNode: SCNNode = SCNNode()

    
    @IBOutlet weak var ligandScene: SCNView! {
        didSet {
            ligandScene.delegate = self
        }
    }
    
    func createShere() -> SCNGeometry {
        let sphere : SCNGeometry = SCNSphere(radius: 0.5)
        sphere.firstMaterial!.diffuse.contents = UIColor.redColor()
        sphere.firstMaterial!.specular.contents = UIColor.whiteColor()
        return sphere
    }
    
    func createScene() -> SCNNode {
        let sceneNode = SCNNode()

        //            CREATE ATOMS
        for atom in self.ligand!.atoms {
            let atomNode = SCNNode(geometry: self.createShere())
            atomNode.position = SCNVector3Make(atom.x!, atom.y!, atom.z!)
            sceneNode.addChildNode(atomNode)
        }
        //            CREATE CONNECTS
        for connect in self.ligand!.connects {
            if let first = self.ligand?.findAtom(connect.0),
                let second = self.ligand?.findAtom(connect.1) {
                let v1 = SCNVector3Make(first.x!, first.y!, first.z!)
                let v2 = SCNVector3Make(second.x!, second.y!, second.z!)
                let connectNode = CylinderLine(parent: sceneNode, v1: v1, v2: v2)
                sceneNode.addChildNode(connectNode)
            }
        }
        return sceneNode
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //        SETUP SCENE
        self.sceneSetup()
        //        CREATE MOLECULE
        self.geometryNode = self.createScene()
        //        DISPLAY MOLECULE
        ligandScene.scene!.rootNode.addChildNode(geometryNode)
    }
    
    func sceneSetup() {
        let scene = SCNScene()
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor(white: 0.67, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = SCNLightTypeOmni
        omniLightNode.light!.color = UIColor(white: 0.75, alpha: 1.0)
        omniLightNode.position = SCNVector3Make(0, 50, 50)
        scene.rootNode.addChildNode(omniLightNode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 100)
        scene.rootNode.addChildNode(cameraNode)

        self.ligandScene.allowsCameraControl = true
        self.ligandScene.autoenablesDefaultLighting = true
        self.ligandScene.scene = scene
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}