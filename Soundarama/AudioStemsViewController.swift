//
//  AudioStemsViewController.swift
//  Soundarama
//
//  Created by Tom Weightman on 09/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//



/* Hi! I'm old and shit.. and soon to be deleted! */

import Foundation
import UIKit

class AudioStemsViewController: UIViewController {
    
    weak var delegate: DJAudioStemPickerUserInterfaceDelegate!
    
    var identifier: String!
    
    var audioStems: Set<UIAudioStem> = Set() {
        
        didSet { sortedAudioStems = audioStems.sort(){ $0.title > $1.title } }
    }
    
    var sortedAudioStems: [UIAudioStem] = []
    
    private var navBar: UINavigationBar
    
    private var tableView: UITableView
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        navBar = UINavigationBar()
        
        tableView = UITableView()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        navBar.pushNavigationItem(UINavigationItem(title: NSLocalizedString("DJ_STEMS_LIST_TITLE", comment: "")), animated: false)
        navBar.titleTextAttributes = [ NSFontAttributeName : UIFont.soundaramaSansSerifRomanFont(size: 18) ]
        
        view.addSubview(navBar)
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        preferredContentSize = CGSize(width: 280.0, height: 400.0)
    }

    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        let titleBarHeight: CGFloat = 44.0
        navBar.frame = CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: titleBarHeight)
        tableView.frame = CGRect(x: 0.0, y: titleBarHeight, width: view.bounds.width, height: view.bounds.height - titleBarHeight)
    }
}

extension AudioStemsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return audioStems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let stem = sortedAudioStems[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier("audio-stem-cell")
        
        if (cell == nil) {
            
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "audio-stem-cell")
        }
        
        cell!.textLabel?.text = stem.title
        cell!.textLabel?.font = UIFont.soundaramaSansSerifBookFont(size: 17)
        cell!.detailTextLabel?.text = stem.subtitle
        cell!.detailTextLabel?.font = UIFont.soundaramaSansSerifBookFont(size: 12)
        cell!.detailTextLabel?.textColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //let audioStemID = sortedAudioStems[indexPath.row].audioStemID
        //delegate?.djAudioStemsUserInterfaceDidSelectStem(self, audioStemID: audioStemID)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 44.0
    }
}
