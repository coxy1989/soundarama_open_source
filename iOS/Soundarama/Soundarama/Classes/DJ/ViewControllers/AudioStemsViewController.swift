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

class AudioStemsViewController: UITableViewController
{
    weak var delegate: AudioStemsViewControllerDelegate?
    
    private var audioStems: [AudioStem]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        self.audioStems = []
        
        if let jsonPath = NSBundle.mainBundle().pathForResource("AudioStems", ofType: "json")
        {
            if let data = NSData(contentsOfFile: jsonPath)
            {
                let json = JSON(data: data)
                if let audioStems = json["AudioStems"].array
                {
                    for audioStemJson in audioStems
                    {
                        if let audioStem = AudioStem(json: audioStemJson)
                        {
                            self.audioStems.append(audioStem)
                        }
                    }
                }
            }
        }
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.preferredContentSize = CGSize(width: 280.0, height: 400.0)
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "audio-stem-cell")
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.audioStems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let stem = self.audioStems[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("audio-stem-cell", forIndexPath: indexPath)
        cell.textLabel?.text = stem.name
        cell.detailTextLabel?.text = stem.category
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.delegate?.audioStemsViewControllerDidSelectStem(self, audioStem: self.audioStems[indexPath.row])
    }
}