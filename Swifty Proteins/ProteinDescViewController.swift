//
//  ProteinDescViewController.swift
//  Swifty Proteins
//
//  Created by Fabien TAFFOREAU on 10/25/16.
//  Copyright © 2016 Fabien TAFFOREAU. All rights reserved.
//

import UIKit



class ProteinDescViewController: UIViewController, NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var pdbxTypeLabel: UILabel!
    @IBOutlet weak var formulaLabel: UILabel!
    @IBOutlet weak var formulaWeightLabel: UILabel!
    
    func fillMolecule() {
        if let name : String = self.infoMolecule["PDBx:name"] {
            self.nameLabel.text = "Name : " + name
        }
        if let type : String = self.infoMolecule["PDBx:type"] {
            self.typeLabel.text = "Type : " + type
        }
        if let pdbxType : String = self.infoMolecule["PDBx:pdbx_type"] {
            self.pdbxTypeLabel.text = "Pdbx Type : " + pdbxType
        }
        if let formula : String = self.infoMolecule["PDBx:formula"] {
            self.formulaLabel.text = "Formula : " + formula
        }
        if let weight : String = self.infoMolecule["PDBx:formula_weight"] {
            self.formulaWeightLabel.text = "Weight : " + weight
        }
    }
    
    @IBOutlet weak var atomTableView: UITableView! {
        didSet {
            atomTableView.dataSource = self
            atomTableView.delegate = self
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.infosAtom.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("atomCell", forIndexPath: indexPath) as! AtomTableCell
        cell.infoAtom = self.infosAtom[indexPath.row]
        return cell
    }
    
    var ligand : Ligand?
    var parser = NSXMLParser()
    var current : (String, String) = ("", "")
    var tmpAtom : [String : String] = [:]
    var infoMolecule : [String : String] = [:]
    var infosAtom : [[String: String]] = []
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if self.current.0 == "molecule" && self.current.1 != ""  {
            self.infoMolecule[self.current.1] = string
        } else if self.current.0 == "atom" && self.current.1 != "" {
            self.tmpAtom[self.current.1] = string
        }
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "PDBx:chem_compCategory" {
            self.current.0 = "molecule"
        } else if elementName == "PDBx:chem_comp_atomCategory" {
            self.current.0 = "atom"
        } else if self.current.0 == "molecule" || self.current.0 == "atom" {
            self.current.1 = elementName
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "PDBx:chem_compCategory" {
            self.current = ("", "")
            self.fillMolecule()
        } else if elementName == "PDBx:chem_comp_atom" {
            self.infosAtom.append(self.tmpAtom)
            self.tmpAtom.removeAll()
        } else if self.current.0 == "molecule" || self.current.0 == "atom" {
            self.current.1 = ""
        }
        if elementName == "PDBx:datablock" {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.atomTableView.reloadData()
            return
        }
    }
    
    func beginParsing()
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.parser = NSXMLParser(contentsOfURL:(NSURL(string: "https://files.rcsb.org/ligands/view/" + self.ligand!.name! + ".xml"))!)!
        self.parser.delegate = self
        self.parser.parse()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.beginParsing()
    }
}

class AtomTableCell : UITableViewCell {
    
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var atomIdLabel: UILabel!
    @IBOutlet weak var chargeLabel: UILabel!
    
    @IBOutlet weak var alignLabel: UILabel!
    
    
    var infoAtom : [String: String]? {
        didSet {
            if let type : String = self.infoAtom?["PDBx:type_symbol"] {
                self.typeLabel.text = "Symbol : " + type
            }
            if let atomId : String = self.infoAtom?["PDBx:pdbx_component_atom_id"] {
                self.atomIdLabel.text = "Atom : " + atomId
            }
            if let charge : String = self.infoAtom?["PDBx:charge"] {
                self.chargeLabel.text = "Charge : " + charge
            }
            if let align : String = self.infoAtom?["PDBx:pdbx_align"] {
                self.alignLabel.text = "Align : " + align
            }            
        }
    }
}
