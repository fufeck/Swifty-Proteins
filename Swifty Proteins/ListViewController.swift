//
//  ListViewController.swift
//  Swifty Proteins
//
//  Created by Fabien TAFFOREAU on 10/20/16.
//  Copyright © 2016 Fabien TAFFOREAU. All rights reserved.
//

import UIKit

struct Atom {
    var nb : Int?
    var name : String?
    var subname : String?
    var x : Float?
    var y : Float?
    var z : Float?
    
    init(tab: [String]) {
        if tab.count >= 12 {
            self.nb = Int(tab[1])
            self.name = tab[11]
            self.subname = tab[2]
            self.x = Float(tab[6])
            self.y = Float(tab[7])
            self.z = Float(tab[8])
        }
    }
}

class Ligand {
    
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
    
    func loadFile(handler : (Bool) -> Void) {
        print("loadfile :", self.name)
        if let urlpath = NSURL(string: "https://files.rcsb.org/ligands/view/" + self.name! + "_model.pdb") {
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
//                        self.connects.append(Connect(tab: tab))
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

extension String {
    func indexOf(string: String) -> String.Index? {
        return lowercaseString.rangeOfString(string.lowercaseString , options: .LiteralSearch, range: nil, locale: nil)?.startIndex
    }
}

class ListViewController: UIViewController, NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var ligands : [Ligand] = []
    var ligandSearch : [Ligand] = []
    
    @IBOutlet weak var ligandSearchBar: UISearchBar! {
        didSet {
            ligandSearchBar.delegate = self
        }
    }
    @IBOutlet weak var ligandTableView: UITableView! {
        didSet {
            ligandTableView.dataSource = self
            ligandTableView.delegate = self
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ligandSearch.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ligandCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.ligandSearch[indexPath.row].name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.ligandSearch[indexPath.row].loadFile {
            (success : Bool) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if success {
                self.performSegueWithIdentifier("LigandSegue", sender: indexPath.row)
            } else {
                let alert = UIAlertView()
                alert.title = "Bad request"
                alert.message = "The liguand " + self.ligandSearch[indexPath.row].name! + " is not find"
                alert.addButtonWithTitle("Ok")
                alert.show()
            }
        }
    }
    
    func LoadLigands() {
        if let urlpath = NSBundle.mainBundle().pathForResource("ligands", ofType: "txt") {
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
        self.ligandSearch = self.ligands
        self.ligandTableView.reloadData()
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.ligandSearch = self.ligands
        } else {
            var tmp : [Ligand] = []
            for ligand in self.ligands {
                if ligand.name?.indexOf(searchText) != nil {
                    tmp.append(ligand)
                }
            }
            self.ligandSearch = tmp
        }
        self.ligandTableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LigandSegue" {
            if let vc = segue.destinationViewController as? ProteinViewController {
                if let i : Int = sender as? Int {
                    vc.ligand = self.ligandSearch[i]
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.LoadLigands()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
