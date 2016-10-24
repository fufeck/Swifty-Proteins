//
//  ProteineInfo.swift
//  Swifty Proteins
//
//  Created by Fabien TAFFOREAU on 10/24/16.
//  Copyright © 2016 Fabien TAFFOREAU. All rights reserved.
//

import Foundation
import UIKit

class Molecule {
    var surname : String?
    var name : String?
    var color : Int?
    var desc : String?
    
    init(tab: [String]) {
        self.surname = tab[0]
        self.name = tab[1]
        self.color = Int(tab[3])
        self.desc = tab[17]
    }
}

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
                        if tab.count >= 18 {
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