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
}

class ProteinInfo {
    static let info : ProteinInfo = ProteinInfo()
    var molecules : [Molecule] = []
    
    init() {
        if let urlpath = NSBundle.mainBundle().pathForResource("pt-data1", ofType: "csv") {
            let filemgr = NSFileManager.defaultManager()
            if filemgr.fileExistsAtPath(urlpath) {
                do {
                    let fullText = try String(contentsOfFile: urlpath, encoding: NSUTF8StringEncoding)
                    let reading = fullText.componentsSeparatedByString("\n") as [String]
                    for line in reading {
                        self.ligands.append(Ligand(name: line))
                    }
                } catch let error as NSError {
                    print("ERROR :", error)
                }
            }
        }
    }
}