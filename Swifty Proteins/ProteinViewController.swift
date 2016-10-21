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
    
    @IBOutlet weak var ligandScene: SCNView! {
        didSet {
            ligandScene.delegate = self
        }
    }
    
    func carbonAtom() -> SCNGeometry {
        let carbonAtom = SCNSphere(radius: 1.70)
        carbonAtom.firstMaterial!.diffuse.contents = UIColor.darkGrayColor()
        carbonAtom.firstMaterial!.specular.contents = UIColor.whiteColor()
        return carbonAtom
    }
    
    func allAtoms() -> SCNNode {
        let atomsNode = SCNNode()
        
        let carbonNode = SCNNode(geometry: carbonAtom())
        carbonNode.position = SCNVector3Make(-6, 0, 0)
        atomsNode.addChildNode(carbonNode)
        
        return atomsNode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}