//
//  AudioStemsViewController.swift
//  Soundarama
//
//  Created by Tom Weightman on 09/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol AudioStemsViewControllerDelegate: class
{
    func audioStemsViewControllerDidSelectStem(audioStemsVC: AudioStemsViewController, audioStem: AudioStem)
}

class AudioStemsViewController: UIViewController
{
    weak var delegate: AudioStemsViewControllerDelegate?
    
    private var navBar: UINavigationBar
    private var tableView: UITableView
    private var audioStems: [AudioStem]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        self.audioStems = JSON.audioStemsFromDisk()
        
        self.navBar = UINavigationBar()
        
        self.tableView = UITableView()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.navBar.pushNavigationItem(UINavigationItem(title: NSLocalizedString("DJ_STEMS_LIST_TITLE", comment: "")), animated: false)
        self.navBar.titleTextAttributes = [ NSFontAttributeName : UIFont.soundaramaSansSerifRomanFont(size: 18) ]
        
        self.view.addSubview(self.navBar)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        
        self.preferredContentSize = CGSize(width: 280.0, height: 400.0)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        let titleBarHeight: CGFloat = 44.0
        self.navBar.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: titleBarHeight)
        self.tableView.frame = CGRect(x: 0.0, y: titleBarHeight, width: self.view.bounds.width, height: self.view.bounds.height - titleBarHeight)
    }
}

extension AudioStemsViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.audioStems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let stem = self.audioStems[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier("audio-stem-cell")
        if (cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "audio-stem-cell")
        }
        
        cell!.textLabel?.text = stem.name
        cell!.textLabel?.font = UIFont.soundaramaSansSerifBookFont(size: 17)
        
        cell!.detailTextLabel?.text = stem.category
        cell!.detailTextLabel?.font = UIFont.soundaramaSansSerifBookFont(size: 12)
        cell!.detailTextLabel?.textColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.delegate?.audioStemsViewControllerDidSelectStem(self, audioStem: self.audioStems[indexPath.row])
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 44.0
    }
}
