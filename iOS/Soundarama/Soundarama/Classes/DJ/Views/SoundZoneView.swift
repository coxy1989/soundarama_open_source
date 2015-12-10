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
    
    weak var delegate: SoundZoneViewDelegate?
    
    private var titleLabel: UILabel
    private var playlistButton: UIButton
    private var ringShapeLayers: [CAShapeLayer]
    
    override init(frame: CGRect)
    {
        self.ringShapeLayers = []
        
        self.playlistButton = UIButton()
        self.playlistButton.setImage(UIImage(named: "btn-playlist")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), forState: .Normal)
        self.playlistButton.layer.borderWidth = 2.0
        
        self.titleLabel = UILabel()
        self.titleLabel.textAlignment = .Center
        self.titleLabel.font = UIFont.soundaramaSansSerifLightFont(size: 14)
        
        super.init(frame: frame)
        
        for i in 0..<Layout.ringFillOpacities.count
        {
            let newShapeLayer = CAShapeLayer()
            newShapeLayer.lineWidth = Layout.ringStrokeWidths[i]
            self.layer.addSublayer(newShapeLayer)
            self.ringShapeLayers.append(newShapeLayer)
        }
        
        self.playlistButton.addTarget(self, action: "didPressPlaylistButton:", forControlEvents: .TouchUpInside)
        self.addSubview(self.playlistButton)
        self.addSubview(self.titleLabel)
        
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
        
        self.titleLabel.textColor = self.tintColor
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
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
        
        //Position button around the circle
        let angle: CGFloat = 5.3
        self.playlistButton.center = CGPoint(x: largestRingRadius * CGFloat(cos(angle)) + centreOfRing.x, y: largestRingRadius * CGFloat(sin(angle)) + centreOfRing.y)
        
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
            self.titleLabel.text = audioStem.name
            self.titleLabel.alpha = 1.0
        }
        else
        {
            self.tintColor = UIColor.darkGrayColor()
            let _ = self.ringShapeLayers.map { $0.opacity = 0.3 }
            self.playlistButton.alpha = 0.3
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
}