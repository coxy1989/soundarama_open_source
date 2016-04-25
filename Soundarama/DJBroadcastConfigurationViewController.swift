//
//  DJBroadcastConfigurationViewController.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

/*
import UIKit
import TouchpressUI

protocol DJBroadcastConfigurationUserInterface: class {
    
    func setIdentifiers(identifiers: [String])
    
    func setReachability(isReachable: Bool)
}

protocol DJBroadcastConfigurationUserInterfaceDelegate: class {
    
    func didRequestAddIdentifier(identifier: String)
}

class DJBroadcastConfigurationViewController: ViewController {
    
    weak var delegate: DJBroadcastConfigurationUserInterfaceDelegate!
    
    private var identifiers: [String] = []
    
    private var isReachable = false
    
    @IBOutlet private weak var textField: UITextField!
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBAction private func textFieldDidPressDone(textField: UITextField) { delegate.didRequestAddIdentifier(textField.text!) }
    
}

extension DJBroadcastConfigurationViewController: DJBroadcastConfigurationUserInterface {
    
    func setIdentifiers(identifiers: [String]) {
        
        self.identifiers = identifiers
        tableView.reloadData()
    }
    
    func setReachability(isReachable: Bool) {
        
        self.isReachable = isReachable
        textField.userInteractionEnabled = isReachable
        textField.text = isReachable ? "Tap here to enter your broadcast name" : "Please connect to the internet"
        tableView.reloadData()
    }
}

extension DJBroadcastConfigurationViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let c = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
        c.titleLabel.text = identifiers[indexPath.row]
        return c
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return identifiers.count
    }
}

extension DJBroadcastConfigurationViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 26
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let c = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
        let v = c.contentView
        c.label.text = sectionTitle()
        return v
    }
}

extension DJBroadcastConfigurationViewController {
    
    func sectionTitle() -> String {
        
        if isReachable {
            
            return identifiers.count == 0 ? "Existing broadcasts will appear below" : "There are \(identifiers.count) existing broadcasts"
        }
            
        else {
            
            return ""
        }
    }
}

 */