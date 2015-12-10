//
//  SoundZoneView.swift
//  Soundarama
//
//  Created by Tom Weightman on 09/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol SoundZoneViewDelegate: class
{
    func soundZoneViewDidPressPaylistButton(soundZoneView: SoundZoneView, playlistButton: UIButton)
    func soundZoneViewDidPressMuteButton(soundZoneView: SoundZoneView, button: UIButton)
    func soundZoneViewDidPressSoloButton(soundZoneView: SoundZoneView, button: UIButton)
    func soundZoneViewDidPressAddNewStemButton(soundZoneView: SoundZoneView, button: UIButton)
}

class SoundZoneView: UIView
{
    struct Layout
    {
        //From outer to inner
        static let ringFillOpacities: [CGFloat] = [ 0.0, 0.15, 0.35, 0.5, 1.0 ]
        static let ringStrokeWidths: [CGFloat] = [ 2.0, 2.0, 2.0, 2.0, 0.0 ]
        static let ringStrokeOpacities: [CGFloat] = [ 0.8, 0.2, 0.5, 0.8, 0.0 ]
        static let ringPadding: CGFloat = 12.0
        static let widthOfEachRing: CGFloat = 28
        static let buttonWidth: CGFloat = 36
    }
    
    var audioStem: AudioStem?
    {
        didSet
        {
            updateForAudioStem()
        }
    }
    
    var muted: Bool = false
    {
        didSet
        {
            if (muted)
            {
                self.tintColor = UIColor.grayColor()
            }
            else if let audioStem = self.audioStem
            {
                self.tintColor = audioStem.colour
            }
        }
    }
    
    var isSolo: Bool = false
    
    weak var delegate: SoundZoneViewDelegate?
    
    private var titleLabel: UILabel
    private var playlistButton: UIButton
    private(set) var muteButton: UIButton
    private var soloButton: UIButton
    private var addNewStemButton: UIButton
    private var ringShapeLayers: [CAShapeLayer]
    
    override init(frame: CGRect)
    {
        self.ringShapeLayers = []
        
        self.playlistButton = UIButton()
        self.playlistButton.setImage(UIImage(named: "btn-playlist")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), forState: .Normal)
        self.playlistButton.layer.borderWidth = 2.0
        
        self.muteButton = UIButton()
        self.muteButton.setTitle(NSLocalizedString("SOUND_ZONE_MUTE", comment: ""), forState: .Normal)
        self.muteButton.titleLabel?.textColor = UIColor.whiteColor()
        self.muteButton.layer.borderWidth = 2.0
        
        self.soloButton = UIButton()
        self.soloButton.setTitle(NSLocalizedString("SOUND_ZONE_SOLO", comment: ""), forState: .Normal)
        self.soloButton.titleLabel?.textColor = UIColor.whiteColor()
        self.soloButton.layer.borderWidth = 2.0
        
        self.titleLabel = UILabel()
        self.titleLabel.textAlignment = .Center
        self.titleLabel.font = UIFont.soundaramaSansSerifLightFont(size: 14)
        
        self.addNewStemButton = UIButton()
        self.addNewStemButton.setTitle(NSLocalizedString("SOUND_ZONE_ADD_NEW_STEM", comment: ""), forState: .Normal)
        self.addNewStemButton.setImage(UIImage(named: "icn-add-new-stem"), forState: .Normal)
        self.addNewStemButton.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 12.0, bottom: 0.0, right: 0.0)
        self.addNewStemButton.titleLabel?.font = UIFont.soundaramaSansSerifRomanFont(size: 14)
        self.addNewStemButton.titleLabel?.textColor = UIColor.whiteColor()
        
        super.init(frame: frame)
        
        self.clipsToBounds = false
        
        for i in 0..<Layout.ringFillOpacities.count
        {
            let newShapeLayer = CAShapeLayer()
            newShapeLayer.lineWidth = Layout.ringStrokeWidths[i]
            self.layer.addSublayer(newShapeLayer)
            self.ringShapeLayers.append(newShapeLayer)
        }
        
        self.playlistButton.addTarget(self, action: "didPressPlaylistButton:", forControlEvents: .TouchUpInside)
        self.muteButton.addTarget(self, action: "didPressMuteButton:", forControlEvents: .TouchUpInside)
        self.soloButton.addTarget(self, action: "didPressSoloButton:", forControlEvents: .TouchUpInside)
        self.addNewStemButton.addTarget(self, action: "didPressAddNewStemButton:", forControlEvents: .TouchUpInside)
        
        self.addSubview(self.playlistButton)
        self.addSubview(self.muteButton)
        self.addSubview(self.soloButton)
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.addNewStemButton)
        
        updateForAudioStem()
    }
    
    override func tintColorDidChange()
    {
        updateForTintColor()
    }
    
    private func updateForTintColor()
    {
        for (idx, opacity) in Layout.ringFillOpacities.enumerate()
        {
            self.ringShapeLayers[idx].fillColor = self.tintColor.colorWithAlphaComponent(opacity).CGColor
            self.ringShapeLayers[idx].strokeColor = self.tintColor.colorWithAlphaComponent(Layout.ringStrokeOpacities[idx]).CGColor
        }
        
        self.playlistButton.backgroundColor = self.tintColor.darkerColor()
        self.playlistButton.layer.borderColor = self.tintColor.CGColor
        
        self.soloButton.backgroundColor = self.playlistButton.backgroundColor
        self.soloButton.layer.borderColor = self.playlistButton.layer.borderColor
        
        self.muteButton.backgroundColor = self.playlistButton.backgroundColor
        self.muteButton.layer.borderColor = self.playlistButton.layer.borderColor
        
        self.titleLabel.textColor = self.tintColor
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.addNewStemButton.frame = self.bounds
        
        updateForTintColor()
        
        let middleSquareSize = min(self.bounds.width, self.bounds.height)
        let middleSquareRect = CGRect(x: (self.bounds.width - middleSquareSize) / 2.0, y: (self.bounds.height - middleSquareSize) / 2.0, width: middleSquareSize, height: middleSquareSize)
        var ringRect = CGRectInset(middleSquareRect, Layout.ringPadding, Layout.ringPadding)
        
        let largestRingRadius = ringRect.width / 2.0
        let centreOfRing = CGPoint(x: ringRect.midX, y: ringRect.midY)
        
        for (idx, ringShapeLayer) in self.ringShapeLayers.enumerate()
        {
            let ringPath = UIBezierPath(ovalInRect: ringRect)
            ringShapeLayer.path = ringPath.CGPath
            
            if (idx == self.ringShapeLayers.count - 2)
            {
                //Last ring is half the jump in size (i.e. it's larger than we'd expect)
                ringRect = CGRectInset(ringRect, Layout.widthOfEachRing / 1.5, Layout.widthOfEachRing / 1.5)
            }
            else
            {
                ringRect = CGRectInset(ringRect, Layout.widthOfEachRing, Layout.widthOfEachRing)
            }
        }
        
        self.playlistButton.frame = CGRect(x: 0.0, y: 0.0, width: Layout.buttonWidth, height: Layout.buttonWidth)
        self.playlistButton.layer.cornerRadius = self.playlistButton.frame.width / 2.0
        
        self.soloButton.frame = CGRect(x: 0.0, y: 0.0, width: Layout.buttonWidth, height: Layout.buttonWidth)
        self.soloButton.layer.cornerRadius = self.soloButton.frame.width / 2.0
        
        self.muteButton.frame = CGRect(x: 0.0, y: 0.0, width: Layout.buttonWidth, height: Layout.buttonWidth)
        self.muteButton.layer.cornerRadius = self.muteButton.frame.width / 2.0
        
        //Position buttons around the circle
        var angle: CGFloat = 5.2
        self.playlistButton.center = CGPoint(x: largestRingRadius * CGFloat(cos(angle)) + centreOfRing.x, y: largestRingRadius * CGFloat(sin(angle)) + centreOfRing.y)
        
        angle += 0.425
        self.muteButton.center = CGPoint(x: largestRingRadius * CGFloat(cos(angle)) + centreOfRing.x, y: largestRingRadius * CGFloat(sin(angle)) + centreOfRing.y)
        
        angle += 0.425
        self.soloButton.center = CGPoint(x: largestRingRadius * CGFloat(cos(angle)) + centreOfRing.x, y: largestRingRadius * CGFloat(sin(angle)) + centreOfRing.y)
        
        //Title to fit in bottom of circle
        self.titleLabel.frame = CGRect(x: 0.0, y: 0.0, width: largestRingRadius, height: 44.0)
        self.titleLabel.center = CGPoint(x: centreOfRing.x, y: centreOfRing.y + (largestRingRadius - Layout.widthOfEachRing)) //one ring in
    }
    
    private func updateForAudioStem()
    {
        if let audioStem = self.audioStem
        {
            self.tintColor = audioStem.colour
            let _ = self.ringShapeLayers.map { $0.opacity = 1.0 }
            
            self.playlistButton.alpha = 1.0
            self.muteButton.alpha = 1.0
            self.soloButton.alpha = 1.0
            
            self.titleLabel.text = audioStem.name
            self.titleLabel.alpha = 1.0
            
            //Fade out add new stem button
            if (self.addNewStemButton.superview != nil)
            {
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    
                    self.addNewStemButton.alpha = 0.0
                    
                    }, completion: { (finished) -> Void in
                        
                        self.addNewStemButton.removeFromSuperview()
                })
            }
        }
        else
        {
            self.tintColor = UIColor.darkGrayColor()
            let _ = self.ringShapeLayers.map { $0.opacity = 0.3 }
            self.playlistButton.alpha = 0.3
            self.muteButton.alpha = 0.3
            self.soloButton.alpha = 0.3
            self.titleLabel.text = NSLocalizedString("SOUND_ZONE_EMPTY", comment: "Empty").uppercaseString
            self.titleLabel.alpha = 0.4
        }
        
        updateForTintColor()
    }
    
    func pointInsideRings(point: CGPoint) -> Bool
    {
        if let largestRing = self.ringShapeLayers.first, path = largestRing.path
        {
            if (CGPathContainsPoint(path, nil, point, false))
            {
                return true
            }
        }
        
        return false
    }
    
    //MARK: Actions
    
    @objc private func didPressPlaylistButton(button: UIButton)
    {
        self.delegate?.soundZoneViewDidPressPaylistButton(self, playlistButton: button)
    }
    
    @objc private func didPressMuteButton(button: UIButton)
    {
        self.delegate?.soundZoneViewDidPressMuteButton(self, button: button)
    }
    
    @objc private func didPressSoloButton(button: UIButton)
    {
        self.delegate?.soundZoneViewDidPressSoloButton(self, button: button)
    }
    
    @objc private func didPressAddNewStemButton(button: UIButton)
    {
        self.delegate?.soundZoneViewDidPressAddNewStemButton(self, button: button)
    }
}