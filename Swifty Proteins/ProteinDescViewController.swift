//
//  ProteinDescViewController.swift
//  Swifty Proteins
//
//  Created by Fabien TAFFOREAU on 10/25/16.
//  Copyright © 2016 Fabien TAFFOREAU. All rights reserved.
//

import UIKit


class ProteinDescViewController: UIViewController, NSXMLParserDelegate {
    
    var ligand : Ligand?
    var parser = NSXMLParser()
    
//    func parser(parser: NSXMLParser, foundCharacters string: String) {
//        print("ONE", ele)
////        if element.isEqualToString("title") {
////            title1.appendString(string)
////        } else if element.isEqualToString("pubDate") {
////            date.appendString(string)
////        }
//    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        print("TWO", elementName)
//        element = elementName
//        if (elementName as NSString).isEqualToString("item")
//        {
//            elements = NSMutableDictionary()
//            elements = [:]
//            title1 = NSMutableString()
//            title1 = ""
//            date = NSMutableString()
//            date = ""
//        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("TREE", elementName)
//        if (elementName as NSString).isEqualToString("item") {
//            if !title1.isEqual(nil) {
//                elements.setObject(title1, forKey: "title")
//            }
//            if !date.isEqual(nil) {
//                elements.setObject(date, forKey: "date")
//            }
//            
//            posts.addObject(elements)
//        }
    }
    
    func beginParsing()
    {
        self.parser = NSXMLParser(contentsOfURL:(NSURL(string: "https://files.rcsb.org/ligands/view/" + self.ligand!.name! + ".xml"))!)!
        self.parser.delegate = self
        self.parser.parse()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.beginParsing()
    }
}