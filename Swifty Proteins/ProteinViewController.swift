//
//  ProteinViewController.swift
//  Swifty Proteins
//
//  Created by Fabien TAFFOREAU on 10/21/16.
//  Copyright © 2016 Fabien TAFFOREAU. All rights reserved.
//

import UIKit
import SceneKit



class ProteinViewController: UIViewController, SCNSceneRendererDelegate {

    var ligand : Ligand?
    // Geometry
    var geometryNode: SCNNode = SCNNode()
    
    // Gestures
    var currentAngle: Float = 0.0
    
    @IBOutlet weak var ligandScene: SCNView! {
        didSet {
            ligandScene.delegate = self
        }
    }
    
    func createAtom() -> SCNGeometry {
        let carbonAtom : SCNGeometry = SCNSphere(radius: 1.70)
        carbonAtom.firstMaterial!.diffuse.contents = UIColor.darkGrayColor()
        carbonAtom.firstMaterial!.specular.contents = UIColor.whiteColor()
        return carbonAtom
    }
    
    func allAtoms() -> SCNNode {
        let atomsNode = SCNNode()
        
        for atom in ligand!.atoms {
            print(atom.x!, atom.y!, atom.z!)
            let atomNode = SCNNode(geometry: createAtom())
//            atomNode.position = SCNVector3Make(+2, 0, 0)
            atomNode.position = SCNVector3Make(atom.x!, atom.y!, atom.z!)
            atomsNode.addChildNode(atomNode)
        }
        
        return atomsNode
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        sceneSetup()
        geometryNode = self.allAtoms()
        ligandScene.scene!.rootNode.addChildNode(geometryNode)
    }
    
    func panGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(sender.view!)
        var newAngle = (Float)(translation.x)*(Float)(M_PI) / 180.0
        newAngle += currentAngle
        
        geometryNode.transform = SCNMatrix4MakeRotation(newAngle, 0, 1, 0)
        
        if(sender.state == UIGestureRecognizerState.Ended) {
            currentAngle = newAngle
        }
    }
    
    // MARK: Scene
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
        cameraNode.position = SCNVector3Make(-3, 44, 100)
//        cameraNode.position = SCNVector3Make(0, 0, 25)
        scene.rootNode.addChildNode(cameraNode)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ProteinViewController.panGesture(_:)))
        ligandScene.addGestureRecognizer(panRecognizer)
        ligandScene.scene = scene
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}