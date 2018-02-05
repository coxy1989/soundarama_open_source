//
//  GameViewController.swift
//  SoundaramaSkiing
//
//  Created by Joseph Thomson on 14/07/2016.
//  Copyright (c) 2016 Touchpress. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    @IBOutlet private var scoreLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        
        let slope = SkiSlope(generator: .SineWave, repeats: true)
        let scene = SkiSlopeScene(slope: slope)
        scene.skiSlopeDelegate = self
        scene.scaleMode = .AspectFit
        skView.presentScene(scene)
    }

    override func shouldAutorotate() -> Bool
    {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            return .Portrait
        }
        else
        {
            return [.Portrait, .PortraitUpsideDown]
        }
    }

    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
}

extension GameViewController: SkiSlopeSceneDelegate
{
    func skiSlopeScene(scene: SkiSlopeScene, didChangeScore score: Int)
    {
        self.scoreLabel.text = "Score: \(score)"
    }
}
