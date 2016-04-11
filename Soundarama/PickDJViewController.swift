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

class PickDJViewController_iPadBackgroundViewController: ViewController {
    
    var onEmbeddedPickDJViewController: (PickDJViewController -> ())!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard segue.identifier == "embedPickDJViewController" else {
            
            return
        }
        
        onEmbeddedPickDJViewController(segue.destinationViewController as! PickDJViewController)
    }
}

class PickDJViewController: ViewController {
    
    weak var delegate: PickDJUserInterfaceDelegate!
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBAction private func didPressDismissButton(sender: AnyObject) { userInterfaceDelegate?.userInterfaceDidNavigateBack(self) }
    
    private var sections: [Section] = []
    
    private var connectionState: ConnectionState = .NotConnected
}

extension PickDJViewController: PickDJUserInterface {
    
    func set(identifier: String?, state: ConnectionState, identifiers: [String], isReachable: Bool) {
        
        print("Reachable: \(isReachable)")
        connectionState = state
        let prestate = sections
        let poststate = [sectionZero(identifier, state: state, isReachable: isReachable), sectionOne(identifiers, isReachable: isReachable)].filter() { $0 != nil }.map() { $0!}
        sections = poststate
        updateTableView(prestate, to: poststate)
    }
    
    private func sectionZero(identifier: String?, state: ConnectionState, isReachable: Bool) -> Section? {
        
        guard isReachable else {
            
            return Section(header: "Please connect to the interwebs", rows: [])
        }
        
        guard let id = identifier else {
            
            return nil
        }
        
        guard state != .NotConnected else {
         
            return nil
        }
        
        let header = state == .Connecting ? "Connecting" : "Connected"
        
        return Section(header: header, rows: [id])
    }
    
    private func sectionOne(identifiers: [String], isReachable: Bool)  -> Section? {
        
        guard isReachable else {
            
            return nil
        }
        
        let header = identifiers.count == 0 ? "There are no available DJs" : "Available DJs"
        
        return Section(header: header, rows: identifiers.sort(<))
    }
}

extension PickDJViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let s = sections[indexPath.section]
        let r = s.rows[indexPath.row]
        let isConnectionCell = sections.count > 1 && indexPath.section == 0
        return isConnectionCell ? connectionCell(r) : availableCell(r)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].rows.count
    }
}

extension PickDJViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 26
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let c = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
        c.label.text = sections[section].header
        let v = c.contentView
        return v
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let valid0 = indexPath.section == 0 && sections.count == 1
        let valid1 = indexPath.section == 1
        let valid = valid0 || valid1
        
        guard valid else {
            
            return
        }
        
        delegate.didPickIdentifier(sections[indexPath.section].rows[indexPath.row])
    }
}

extension PickDJViewController {
    
    private func updateTableView(from: [Section], to: [Section]) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock() { [weak self] in self?.tableView.reloadData() }
        
        tableView.beginUpdates()
        tableView.insertSections(insertedSections(from, to: to), withRowAnimation: .Automatic)
        tableView.deleteSections(deletedSections(from, to: to), withRowAnimation: .Automatic)
        tableView.insertRowsAtIndexPaths(insertedRows(from, to: to), withRowAnimation: .Automatic)
        tableView.deleteRowsAtIndexPaths(deletedRows(from, to: to), withRowAnimation: .Automatic)
        tableView.endUpdates()
        
        CATransaction.commit()
    }
    
    private func insertedSections(from: [Section], to: [Section]) -> NSIndexSet {
        
        let preidx = from.enumerate().map() { $0.index }, postidx = to.enumerate().map() { $0.index }
        let inserted_sections = Set(postidx).subtract(Set(preidx))
        let indexSet = NSMutableIndexSet()
        inserted_sections.forEach() { indexSet.addIndex($0) }
        return indexSet
    }
    
    private func insertedRows(from: Section, to: Section) -> NSIndexSet {
        
        let preidx = from.rows.enumerate().map() { $0.index }, postidx = to.rows.enumerate().map() { $0.index }
        let inserted_rows = Set(postidx).subtract(Set(preidx))
        let indexSet = NSMutableIndexSet()
        inserted_rows.forEach() { indexSet.addIndex($0) }
        return indexSet
    }
    
    private func deletedSections(from: [Section], to: [Section]) -> NSIndexSet {
        
        let preidx = from.enumerate().map() { $0.index }, postidx = to.enumerate().map() { $0.index }
        let deleted_sections = Set(preidx).subtract(Set(postidx))
        let indexSet = NSMutableIndexSet()
        deleted_sections.forEach() { indexSet.addIndex($0) }
        return indexSet
    }
    
    private func deletedRows(from: Section, to: Section) -> NSIndexSet {
        
        let preidx = from.rows.enumerate().map() { $0.index }, postidx = to.rows.enumerate().map() { $0.index }
        let deleted_rows = Set(preidx).subtract(Set(postidx))
        let indexSet = NSMutableIndexSet()
        deleted_rows.forEach() { indexSet.addIndex($0) }
        return indexSet
    }
    
    private func insertedRows(from: [Section], to: [Section]) -> [NSIndexPath] {
        
        return Array(zip(from, to).enumerate().map() { idx, secs in insertedRows(secs.0, to: secs.1).map() { NSIndexPath(forRow: $0, inSection: idx )}}.flatten())
    }
    
    private func deletedRows(from: [Section], to: [Section]) -> [NSIndexPath] {
        
        return Array(zip(from, to).enumerate().map() { idx, secs in deletedRows(secs.0, to: secs.1).map() { NSIndexPath(forRow: $0, inSection: idx )}}.flatten())
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
    
    func availableCell(identifier: String) -> UITableViewCell {
        
        let c = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
        c.titleLabel.text = identifier
        return c
    }
}

private struct Section: Hashable {
    
    let header: String
    let rows: [String]
    
    private var hashValue: Int {
        
        return header.hash ^ rows.reduce(0) { $0 ^ $1.hashValue }
    }
}

private func == (lhs: Section, rhs: Section) -> Bool {
    
    let eq_rows = zip(lhs.rows, rhs.rows).map() { $0.0 == $0.1 }.filter() { $0 == false }.count == 0
    let eq_headers = lhs.header == rhs.header
    return eq_rows && eq_headers
}
