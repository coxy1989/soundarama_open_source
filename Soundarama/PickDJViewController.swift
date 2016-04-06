//
//  PerformerConnectionViewController.swift
//  Soundarama
//
//  Created by Jamie Cox on 04/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit
import TouchpressUI

protocol PickDJUserInterface: class {
    
    func set(identifier: String?, state: ConnectionState, identifiers: [String], isReachable: Bool)
}

protocol PickDJUserInterfaceDelegate: class {
    
    func didPickIdentifier(identifier: String)
}

class PickDJViewController: ViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func didPressDismissButton(sender: AnyObject) { userInterfaceDelegate?.userInterfaceDidNavigateBack(self) }
    
    weak var delegate: PickDJUserInterfaceDelegate!
    
    private var identifiers: [String] = []
    
    private var isReachable = false
    
    private var connectionIdentifier: String?
    
    private var connectionState = ConnectionState.NotConnected
}

extension PickDJViewController: PickDJUserInterface {
    
    func set(identifier: String?, state: ConnectionState, identifiers: [String], isReachable: Bool) {
        
        connectionIdentifier = identifier
        connectionState = state
        self.identifiers = identifiers
        self.isReachable = isReachable
        tableView.reloadData()
        print("\(identifier), \(state), \(identifiers), \(isReachable)")
    }
}

extension PickDJViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        guard isReachable else {
            
            return 1
        }
        
        switch connectionState {
            
            case .Connected, .Connecting:
                
                return identifiers.count == 0 ? 1 : 2
            
            case .NotConnected:
            
                return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        if let identifier = connectionIdentifier where indexPath.section == 0 && connectionState != .NotConnected {
            
            return connectionCell(identifier)
        }
        
        return availableCell(indexPath.row)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if connectionIdentifier != nil && section == 0 && connectionState != .NotConnected {
            
            return 1
        }
        
        return identifiers.count
    }
}

extension PickDJViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 26
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let c = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
        let v = c.contentView
        c.label.text = sectionTitle(section)
        return v
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if connectionIdentifier != nil && indexPath.section == 0 {
            
            /* This isn't an identifier, its the connected identifier */
            return
        }
        
        let id = identifiers[indexPath.row]
        delegate.didPickIdentifier(id)
    }
}

extension PickDJViewController {
    
    func connectionCell(identifier: String) -> UITableViewCell {
        
        let c = tableView.dequeueReusableCellWithIdentifier("ActivityIndicatorCell") as! ActivityIndicatorCell
        c.titleLabel.text = identifier
        
        if connectionState == .Connected {
            
            c.activityIndicator.stopAnimating()
            c.activityIndicator.hidden = true
            c.checkmark.hidden = false
        }
            
        else if connectionState == .Connecting {
            
            c.activityIndicator.startAnimating()
            c.activityIndicator.hidden = false
            c.checkmark.hidden = true
        }
        
        return c
    }
    
    func availableCell(row: Int) -> UITableViewCell {
        
        let c = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
        c.titleLabel.text = identifiers[row]
        return c
    }
}

extension PickDJViewController {
    
    func sectionTitle(section: Int) -> String {
        
        guard isReachable else {
            
            return "Please connect to the interwebs"
        }
        
        guard connectionState != .NotConnected else {
            
            return identifiers.count == 0 ? "There are no available DJs" : "Available"
        }
        
        if section == 0 {
            
            return connectionState == .Connected ? "Connected" : "Connecting"
        }
        
        if section == 1 {
            
            return identifiers.count == 0 ? "There are no available DJs" : "Available"
        }
        
        return "This is a logical error"
    }
}
