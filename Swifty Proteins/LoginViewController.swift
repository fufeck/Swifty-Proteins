//
//  LoginViewController.swift
//  Swifty Proteins
//
//  Created by Fabien TAFFOREAU on 10/20/16.
//  Copyright © 2016 Fabien TAFFOREAU. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    
    let context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if self.context.canEvaluatePolicy(.DeviceOwnerAuthentication, error: nil) {
            context.evaluatePolicy(.DeviceOwnerAuthentication, localizedReason: "To user App") {
                (success, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    // code here
                    if success {
                        self.performSegueWithIdentifier("ListSegue", sender: "Foo")
                    } else {
                        let alert = UIAlertView()
                        alert.title = "Bad authentification"
                        alert.message = "Ypu can't access to apllication because your authentification is wrong"
                        alert.addButtonWithTitle("Ok")
                        alert.show()
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
}


