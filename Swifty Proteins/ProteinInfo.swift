//
//  ProteineInfo.swift
//  Swifty Proteins
//
//  Created by Fabien TAFFOREAU on 10/24/16.
//  Copyright © 2016 Fabien TAFFOREAU. All rights reserved.
//

import Foundation
import UIKit

//EXTENSION

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}


extension String {
    func indexOf(string: String) -> String.Index? {
        return lowercaseString.rangeOfString(string.lowercaseString , options: .LiteralSearch, range: nil, locale: nil)?.startIndex
    }
}

//MOLECULE

class Molecule {
    var surname : String?
    var name : String?
    var color : UIColor?
    var desc : String?
    
    init(tab: [String]) {
        self.surname = tab[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.name = tab[2].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.desc = tab[tab.count - 2].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if let color = UInt(tab[4], radix: 16) {
            self.color = UIColor(netHex: Int(color))
        } else {
            self.color = UIColor.whiteColor()
        }
    }
}

//PROTEIN

class ProteinInfo {
    static let info : ProteinInfo = ProteinInfo()
    var molecules : [Molecule] = []
    
    func find(name : String) -> Molecule? {
        for molecule in molecules {
            if molecule.surname == name {
                return molecule
            }
        }
        return nil
    }
    
    init() {
        if let urlpath = NSBundle.mainBundle().pathForResource("pt-data1", ofType: "csv") {
            let filemgr = NSFileManager.defaultManager()
            if filemgr.fileExistsAtPath(urlpath) {
                do {
                    let fullText = try String(contentsOfFile: urlpath, encoding: NSUTF8StringEncoding)
                    let reading = fullText.componentsSeparatedByString("\n") as [String]
                    for line in reading {
                        let tab = line.componentsSeparatedByString(",") as [String]
                        if tab.count >= 19 {
                            self.molecules.append(Molecule(tab: tab))
                        }
                    }
                } catch let error as NSError {
                    print("ERROR :", error)
                }
            }
        }
    }
}

//ATOM

struct Atom {
    var nb : Int?
    var x : Float?
    var y : Float?
    var z : Float?
    var info : Molecule?
    
    init(tab: [String]) {
        if tab.count >= 12 {
            self.nb = Int(tab[1])
            self.x = Float(tab[6])
            self.y = Float(tab[7])
            self.z = Float(tab[8])
            self.info = ProteinInfo.info.find(tab[11])
        }
    }
}

//LIGAND

class Ligand {
//    https://files.rcsb.org/ligands/view/HEM.xml
    var name : String?
    var atoms : [Atom] = []
    var connects : [(Int, Int)] = []
    
    func findAtom(nb : Int) -> Atom? {
        for atom in self.atoms { if atom.nb == nb { return atom } }
        return nil
    }
    
    
    func connectExist(a:[(Int, Int)], v:(Int,Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }
    
    func createConnect(tab: [String]) {
        var i = 2
        while i < tab.count {
            if !self.connectExist(self.connects, v: (Int(tab[1])!, Int(tab[i])!)) {
                self.connects.append((Int(tab[1])!, Int(tab[i])!))
            }
            i = i + 1
        }
    }

    func loadDescription(handler : (Bool) -> Void) {
        if let urlpath = NSURL(string: "https://files.rcsb.org/ligands/view/" + self.name! + "_ideal.pdb") {
            do {
                let fullText = try String(contentsOfURL: urlpath)
                let reading = fullText.componentsSeparatedByString("\n") as [String]
                for line in reading {
                    var tab = line.componentsSeparatedByString(" ") as [String]
                    tab = tab.filter{$0 != ""}
                    if tab.count >= 12 && tab[0] == "ATOM" {
                        self.atoms.append(Atom(tab: tab))
                    } else if tab.count > 1 && tab[0] == "CONECT" {
                        self.createConnect(tab)
                    }
                }
                return handler(true)
            } catch let error as NSError {
                print("ERROR :", error)
            }
        }
        return handler(false)
    }

    
    func loadFile(handler : (Bool) -> Void) {
        if let urlpath = NSURL(string: "https://files.rcsb.org/ligands/view/" + self.name! + "_ideal.pdb") {
            do {
                let fullText = try String(contentsOfURL: urlpath)
                let reading = fullText.componentsSeparatedByString("\n") as [String]
                for line in reading {
                    var tab = line.componentsSeparatedByString(" ") as [String]
                    tab = tab.filter{$0 != ""}
                    if tab.count >= 12 && tab[0] == "ATOM" {
                        self.atoms.append(Atom(tab: tab))
                    } else if tab.count > 1 && tab[0] == "CONECT" {
                        self.createConnect(tab)
                    }
                }
                return handler(true)
            } catch let error as NSError {
                print("ERROR :", error)
            }
        }
        return handler(false)
    }
    
    init(name : String) {
        self.name = name
    }
}

