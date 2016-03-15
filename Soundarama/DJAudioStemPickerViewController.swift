//
//  DJAudioStemPickerViewController.swift
//  Soundarama
//
//  Created by Jamie Cox on 14/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit
import TouchpressUI

class DJAudioStemPickerViewController: ViewController, DJAudioStemPickerUserInterface {
    
    var keys: [String]!
    
    var colors: [String : UIColor]!
    
    var stemsIndex: [String : [String : Set<UIAudioStem>]]!
    
    var identifier: String!
    
    weak var delegate: DJAudioStemPickerUserInterfaceDelegate!
    
    @IBAction func backButtonWasPressed(sender: AnyObject) { userInterfaceDelegate?.userInterfaceDidNavigateBack(self) }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet private weak var button0: UnderlinedTextButton!
    
    @IBOutlet private weak var button1: UnderlinedTextButton!
    
    @IBOutlet private weak var button2: UnderlinedTextButton!
    
    @IBOutlet private weak var button3: UnderlinedTextButton!
    
    @IBOutlet private weak var button4: UnderlinedTextButton!
    
    @IBOutlet private weak var button5: UnderlinedTextButton!
    
    @IBAction func buttonWasPressed(sender: UnderlinedTextButton) { delegate.didRequestSetSelectedKey(self, key: keys[buttons.indexOf(sender)!]) }
    
    private lazy var buttons: [UnderlinedTextButton] = { [unowned self] in
        
        return [self.button0, self.button1, self.button2, self.button3, self.button4, self.button5]
    }()
    
    private var lastSelectedKey: String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        buttons.enumerate().forEach() { idx, b in
            let k = keys[idx]
            b.setTitle(k, forState: .Normal)
            b.setTitleColor(colors[k], forState: .Normal)
            b.setUnderlineColor(UIColor.clearColor())
        }
    }
    
    func setSelectedKey(key: String) {
        
        let selected = buttons[keys.indexOf(key)!]
        let unselected = buttons.filter() { $0 != selected }
        selected.setUnderlineColor(colors[key])
        unselected.forEach() { $0.setUnderlineColor(UIColor.clearColor())}
        lastSelectedKey = key
        tableView.reloadData()
    }
}

extension DJAudioStemPickerViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return stemsIndex[lastSelectedKey]!.keys.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let orderedKeys = stemsIndex[lastSelectedKey]!.keys.sort() { $0 > $1 }
        let key = orderedKeys[section]
        let stems = stemsIndex[lastSelectedKey]![key]!
        return stems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let c = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
        let stem = audioStem(indexPath)
        c.titleLabel.text = stem.title
        c.subtitleLabel.text = stem.subtitle
        c.titleLabel.textColor = stem.colour
        return c
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let c = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
        let orderedKeys = stemsIndex[lastSelectedKey]!.keys.sort() { $0 > $1 }
        let key = orderedKeys[section]
        let v = c.contentView
        c.label.text = key
        return v
    }
}

extension DJAudioStemPickerViewController {
    
    func audioStem(indexPath: NSIndexPath) -> UIAudioStem {

        return orderedStems(indexPath.section)[indexPath.row]
    }
    
    func orderedStems(section: Int) -> [UIAudioStem] {
        
        let orderedKeys = stemsIndex[lastSelectedKey]!.keys.sort() { $0 > $1 }
        let key = orderedKeys[section]
        return stemsIndex[lastSelectedKey]![key]!.sort() {$0.title > $1.title}
    }
}

extension DJAudioStemPickerViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
  
        let stem = orderedStems(indexPath.section)[indexPath.row]
        delegate.didRequestSelectStem(self, audioStemID:stem.audioStemID)
    }
}
