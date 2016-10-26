//
//  ListViewController.swift
//  Swifty Proteins
//
//  Created by Fabien TAFFOREAU on 10/20/16.
//  Copyright © 2016 Fabien TAFFOREAU. All rights reserved.
//

import UIKit

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
                    vc.title = "View " + self.ligandSearch[i].name!
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
