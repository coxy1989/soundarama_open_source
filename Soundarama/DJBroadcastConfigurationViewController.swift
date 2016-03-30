//
//  DJBroadcastConfigurationViewController.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit
import TouchpressUI

protocol DJBroadcastConfigurationUserInterface: class {
    
    func setIdentifiers(identifiers: [String])
}

protocol DJBroadcastConfigurationUserInterfaceDelegate: class {
    
    func didRequestAddIdentifier(identifier: String)
}

class DJBroadcastConfigurationViewController: ViewController {
    
    weak var delegate: DJBroadcastConfigurationUserInterfaceDelegate!
    
    private var identifiers: [String] = []
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBAction private func textFieldDidPressDone(textField: UITextField) { delegate.didRequestAddIdentifier(textField.text!) }
    
}

extension DJBroadcastConfigurationViewController: DJBroadcastConfigurationUserInterface {
    
    func setIdentifiers(identifiers: [String]) {
        
        self.identifiers = identifiers
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
        let text = identifiers.count == 0 ? "Existing broadcasts will appear below" : "There are \(identifiers.count) existing broadcasts"
        c.label.text = text
        return v
    }
}
