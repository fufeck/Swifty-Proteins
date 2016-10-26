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

class   AtomSphere: SCNNode
{
    var atom : Atom?
    
    init(geometry : SCNGeometry, atom : Atom) {
        super.init()
        self.geometry = geometry
        self.atom = atom
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DescSegue" {
            if let vc = segue.destinationViewController as? ProteinDescViewController {
                    vc.ligand = self.ligand
                    vc.title = "Description " + self.ligand!.name!
            }
        }
    }
    
    @IBAction func changeScene(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0:
            self.ligandScene.scene!.rootNode.replaceChildNode(self.SpaceFillingScene, with: self.ballAndStickScene)
        case 1:
            self.ligandScene.scene!.rootNode.replaceChildNode(self.ballAndStickScene, with: self.SpaceFillingScene)
        default:
            break; 
        }
    }
    
    @IBAction func shareScreenAction(sender: UIBarButtonItem) {
        let image : UIImage = self.ligandScene.snapshot()
        
        let imageToShare = [ image ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        
        activityViewController.excludedActivityTypes = [ UIActivityTypePrint, UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo, UIActivityTypePostToFacebook ]
        
        // present the view controller
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var atomLabel: UILabel!
    
    var ligand : Ligand?
    // Geometry
    var ballAndStickScene: SCNNode = SCNNode()
    var SpaceFillingScene: SCNNode = SCNNode()

    
    @IBOutlet weak var ligandScene: SCNView! {
        didSet {
            ligandScene.delegate = self
        }
    }
    
    func createAtom(sceneNode : SCNNode, atom : Atom, radius : CGFloat) {
        let sphere : SCNGeometry = SCNSphere(radius: radius)
        sphere.firstMaterial!.diffuse.contents = atom.info?.color
        sphere.firstMaterial!.specular.contents = UIColor.whiteColor()
        let atomNode = AtomSphere(geometry: sphere, atom: atom)
        atomNode.position = SCNVector3Make(atom.x!, atom.y!, atom.z!)
        sceneNode.addChildNode(atomNode)
    }

    func createConnect(sceneNode : SCNNode, connect : (Int, Int)) {
        if let first = self.ligand?.findAtom(connect.0),
            let second = self.ligand?.findAtom(connect.1) {
            let v1 = SCNVector3Make(first.x!, first.y!, first.z!)
            let v2 = SCNVector3Make(second.x!, second.y!, second.z!)
            let connectNode = CylinderLine(parent: sceneNode, v1: v1, v2: v2)
            sceneNode.addChildNode(connectNode)
        }
    }
    
    func createSceneBallAndStick() {
        for atom in self.ligand!.atoms {
            self.createAtom(self.ballAndStickScene, atom: atom, radius: 0.4)
        }
        for connect in self.ligand!.connects {
            self.createConnect(self.ballAndStickScene, connect: connect)
        }
    }

    func createSceneSpaceFilling() {

        for atom in self.ligand!.atoms {
            self.createAtom(self.SpaceFillingScene, atom: atom, radius: 1)
        }
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
        cameraNode.position = SCNVector3Make(0, 0, 50)
        scene.rootNode.addChildNode(cameraNode)

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProteinViewController.handleTap(_:)))
        var gestureRecognizers : [UIGestureRecognizer] = []
        gestureRecognizers.append(tapGesture)
        self.ligandScene.gestureRecognizers = gestureRecognizers
        
        self.ligandScene.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        self.ligandScene.allowsCameraControl = true
        self.ligandScene.autoenablesDefaultLighting = true
        self.ligandScene.scene = scene
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        let location = gestureRecognize.locationInView(self.ligandScene)
        let hits = self.ligandScene.hitTest(location, options: nil)
        if let tappedNode = hits.first?.node {
            if let atomNode = tappedNode as? AtomSphere {
                if let surname : String = atomNode.atom?.info?.surname,
                let name : String = atomNode.atom?.info?.name,
                let desc : String = atomNode.atom?.info?.desc {
                    self.atomLabel.text = surname + ", " + name + ", " + desc
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.ligandScene.scene == nil {
            super.viewDidAppear(animated)
            //        SETUP SCENE
            self.sceneSetup()
            //        DISPLAY MOLECULE
            self.ligandScene.scene!.rootNode.addChildNode(self.ballAndStickScene)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        CREATE BALL AND STICK VIEW
        self.createSceneBallAndStick()
        self.createSceneSpaceFilling()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}