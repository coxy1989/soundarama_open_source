//
//  SoundZoneView.swift
//  Soundarama
//
//  Created by Tom Weightman on 09/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol SoundZoneViewDelegate: class {
    
    func soundZoneViewDidChangeMuteState(soundZoneView: SoundZoneView)
    
    func soundZoneViewDidChangeSoloState(soundZoneView: SoundZoneView)
    
    func soundZoneViewDidRequestStemChange(soundZoneView: SoundZoneView)
}

class SoundZoneView: UIView {
    
    weak var delegate: SoundZoneViewDelegate?
    
    var color = UIColor.darkGrayColor() {
     
        didSet {
            updateWithColor(color)
        }
    }
    
    var title = "Placeholder" {
        
        didSet {
            titleLabel.text = title
        }
    }
    
    var soloSelected = false {
        
        didSet {
            soloButton.selected = soloSelected
        }
    }
    
    var muteSelected = false {
        
        didSet {
            muteButton.selected = muteSelected
        }
    }
    
    func hideAddStemControl() {
        
        guard addNewStemButton.superview != nil else {
            return
        }
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { [weak self] in
            self?.addNewStemButton.alpha = 0.0
            }) {[weak self] done in
                self?.addNewStemButton.removeFromSuperview()
        }
    }
    
    func setAlphaRegular() {
        
        for l in ringShapeLayers {
            l.opacity = 1
        }
        
        playlistButton.alpha = 1
        muteButton.alpha = 1
        soloButton.alpha = 1
        titleLabel.alpha = 1
    }
    
    private struct Layout {
        
        /* Outer -> Innner */
        static let ringFillOpacities: [CGFloat] = [ 0.0, 0.15, 0.35, 0.5, 1.0 ]
        static let ringStrokeWidths: [CGFloat] = [ 2.0, 2.0, 2.0, 2.0, 0.0 ]
        static let ringStrokeOpacities: [CGFloat] = [ 0.8, 0.2, 0.5, 0.8, 0.0 ]
        static let ringPadding: CGFloat = 12.0
        static let widthOfEachRing: CGFloat = 28
        static let buttonWidth: CGFloat = 36
    }
    
    private lazy var titleLabel: UILabel  = { [unowned self] in
       
        let l = UILabel()
        l.textAlignment = .Center
        l.font = UIFont.avenirLight(14)
        l.textColor = UIColor.whiteColor()
        return l
    }()
    
    private lazy var playlistButton: UIButton = {
       
        let b = UIButton()
        b.setImage(UIImage(named: "btn-playlist")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), forState: .Normal)
        b.layer.borderWidth = 2.0
        b.addTarget(self, action: #selector(SoundZoneView.didPressPlaylistButton), forControlEvents: .TouchUpInside)
        return b
    }()
    
    private lazy var muteButton: UIButton = {
       
        let b = UIButton()
        b.setTitle("M", forState: .Normal)
        b.setTitleColor(UIColor.blackColor(), forState: .Normal)
        b.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: .Selected)
        b.layer.borderWidth = 2.0
        b.addTarget(self, action: #selector(SoundZoneView.didPressMuteButton), forControlEvents: .TouchUpInside)
        return b
    }()
    
    private lazy var soloButton: UIButton = {
        
        let b = UIButton()
        b.setTitle("S", forState: .Normal)
        b.setTitleColor(UIColor.blackColor(), forState: .Normal)
        b.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: .Selected)
        b.layer.borderWidth = 2.0
        b.addTarget(self, action: #selector(SoundZoneView.didPressSoloButton), forControlEvents: .TouchUpInside)
        return b
    }()
    
    private lazy var addNewStemButton: UIButton = {
        
        let b = UIButton()
        b.setTitle("SOUND_ZONE_ADD_NEW_STEM".localizedString, forState: .Normal)
        b.setImage(UIImage(named: "icn-add-new-stem"), forState: .Normal)
        b.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 12.0, bottom: 0.0, right: 0.0)
        b.titleLabel?.font = UIFont.avenirRoman(14)
        b.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        b.clipsToBounds = true
        b.addTarget(self, action: #selector(SoundZoneView.didPressAddNewStemButton), forControlEvents: .TouchUpInside)
        return b
    }()
    
    private var ringShapeLayers: [CAShapeLayer] = []
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        clipsToBounds = false
        addRings()
        addControls()
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        /* Colors */
        
        updateWithColor(color)
        
        /* Rings */
        
        //let middleSquareSize = min(bounds.width, bounds.height)
        //let middleSquareRect = CGRect(x: (bounds.width - middleSquareSize) / 2.0, y: (bounds.height - middleSquareSize) / 2.0, width: middleSquareSize, height: middleSquareSize)
        //var ringRect = CGRectInset(middleSquareRect, Layout.ringPadding, Layout.ringPadding)
        //let largestRingRadius = ringRect.width / 2.0
        //let centreOfRing = CGPoint(x: ringRect.midX, y: ringRect.midY)
        
        
        let middleSquareSize = min(bounds.width, bounds.height)
        let middleSquareRect = CGRect(x: (bounds.width - middleSquareSize) / 2.0, y: (bounds.height - middleSquareSize) / 2.0, width: middleSquareSize, height: middleSquareSize)
        var ringRect = CGRectInset(middleSquareRect, Layout.ringPadding, Layout.ringPadding)
        let largestRingRadius = ringRect.width / 2.0
        let centreOfRing = CGPoint(x: ringRect.midX, y: ringRect.midY)
        
        for (idx, ringShapeLayer) in ringShapeLayers.enumerate() {
            
            let ringPath = UIBezierPath(ovalInRect: ringRect)
            ringShapeLayer.path = ringPath.CGPath
            
            if (idx == ringShapeLayers.count - 2) {
                ringRect = CGRectInset(ringRect, Layout.widthOfEachRing / 1.5, Layout.widthOfEachRing / 1.5)
            }
            else {
                ringRect = CGRectInset(ringRect, Layout.widthOfEachRing, Layout.widthOfEachRing)
            }
        }
        
        /* Controls */
        
        addNewStemButton.frame = bounds
        addNewStemButton.layer.cornerRadius = bounds.size.width * 0.5
        playlistButton.frame = CGRect(x: 0.0, y: 0.0, width: Layout.buttonWidth, height: Layout.buttonWidth)
        playlistButton.layer.cornerRadius = playlistButton.frame.width / 2.0
        soloButton.frame = CGRect(x: 0.0, y: 0.0, width: Layout.buttonWidth, height: Layout.buttonWidth)
        soloButton.layer.cornerRadius = soloButton.frame.width / 2.0
        muteButton.frame = CGRect(x: 0.0, y: 0.0, width: Layout.buttonWidth, height: Layout.buttonWidth)
        muteButton.layer.cornerRadius = muteButton.frame.width / 2.0
        
        
        var angle: CGFloat = 5.2
        playlistButton.center = CGPoint(x: largestRingRadius * CGFloat(cos(angle)) + centreOfRing.x, y: largestRingRadius * CGFloat(sin(angle)) + centreOfRing.y)
        angle += 0.425
        muteButton.center = CGPoint(x: largestRingRadius * CGFloat(cos(angle)) + centreOfRing.x, y: largestRingRadius * CGFloat(sin(angle)) + centreOfRing.y)
        angle += 0.425
        soloButton.center = CGPoint(x: largestRingRadius * CGFloat(cos(angle)) + centreOfRing.x, y: largestRingRadius * CGFloat(sin(angle)) + centreOfRing.y)
        
        
        /* Title Button */
        
        titleLabel.frame = CGRect(x: 0.0, y: 0.0, width: largestRingRadius, height: 44.0)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: centreOfRing.x, y: centreOfRing.y + (largestRingRadius - Layout.widthOfEachRing))
    }
}

extension SoundZoneView {
    
    func updateWithColor(color: UIColor) {
        
        for (idx, opacity) in Layout.ringFillOpacities.enumerate() {
            ringShapeLayers[idx].fillColor = color.colorWithAlphaComponent(opacity).CGColor
            ringShapeLayers[idx].strokeColor = color.colorWithAlphaComponent(Layout.ringStrokeOpacities[idx]).CGColor
        }
        
        playlistButton.backgroundColor = color.lighterColor()
        playlistButton.layer.borderColor = color.CGColor
        
        soloButton.backgroundColor = playlistButton.backgroundColor
        soloButton.layer.borderColor = playlistButton.layer.borderColor
        
        muteButton.backgroundColor = playlistButton.backgroundColor
        muteButton.layer.borderColor = playlistButton.layer.borderColor
        
        titleLabel.textColor = color
    }
}

extension SoundZoneView {
    
    func pointIsInsideRings(point: CGPoint) -> Bool {
        
        if let largestRing = ringShapeLayers.first, path = largestRing.path {
            if (CGPathContainsPoint(path, nil, point, false)) {
                return true
            }
        }
    
        return false
    }
}

extension SoundZoneView {
    
    @objc private func didPressPlaylistButton() {
        
        delegate?.soundZoneViewDidRequestStemChange(self)
    }
    
    @objc private func didPressMuteButton() {
        
        delegate?.soundZoneViewDidChangeMuteState(self)
    }
    
    @objc private func didPressSoloButton() {
        
        delegate?.soundZoneViewDidChangeSoloState(self)
    }
    
    @objc private func didPressAddNewStemButton() {
        
        delegate?.soundZoneViewDidRequestStemChange(self)
    }
}

extension SoundZoneView {
    
    func addControls() {
        
        let controls = [addNewStemButton, playlistButton, muteButton, soloButton, titleLabel]
        for c in controls {
            addSubview(c)
        }
    }
    
    func addRings() {
        
        for i in 0..<Layout.ringFillOpacities.count {
            let newShapeLayer = CAShapeLayer()
            newShapeLayer.lineWidth = Layout.ringStrokeWidths[i]
            layer.addSublayer(newShapeLayer)
            ringShapeLayers.append(newShapeLayer)
        }
    }
}

class SoundZoneView_TopAligned: SoundZoneView {
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        /* Controls */
        
        playlistButton.frame = CGRect(x: 0.0, y: 0.0, width: Layout.buttonWidth, height: Layout.buttonWidth)
        playlistButton.layer.cornerRadius = playlistButton.frame.width / 2.0
        soloButton.frame = CGRect(x: 0.0, y: 0.0, width: Layout.buttonWidth, height: Layout.buttonWidth)
        soloButton.layer.cornerRadius = soloButton.frame.width / 2.0
        muteButton.frame = CGRect(x: 0.0, y: 0.0, width: Layout.buttonWidth, height: Layout.buttonWidth)
        muteButton.layer.cornerRadius = muteButton.frame.width / 2.0
        
        let middleSquareSize = min(bounds.width, bounds.height)
        let middleSquareRect = CGRect(x: (bounds.width - middleSquareSize) / 2.0, y: (bounds.height - middleSquareSize) / 2.0, width: middleSquareSize, height: middleSquareSize)
        let ringRect = CGRectInset(middleSquareRect, Layout.ringPadding, Layout.ringPadding)
        let centreOfRing = CGPoint(x: ringRect.midX, y: ringRect.midY)
        let largestRingRadius = ringRect.width / 2.0
        
        let angle: CGFloat = CGFloat(M_PI  + M_PI_2)
        playlistButton.center = CGPoint(x: largestRingRadius * CGFloat(cos(angle)) + centreOfRing.x, y: largestRingRadius * CGFloat(sin(angle)) + centreOfRing.y)
        let spacing = CGFloat(M_PI / 5)
        let loc = angle - spacing
        muteButton.center = CGPoint(x: largestRingRadius * CGFloat(cos(loc)) + centreOfRing.x, y: largestRingRadius * CGFloat(sin(loc)) + centreOfRing.y)
        let roc = angle + spacing
        soloButton.center = CGPoint(x: largestRingRadius * CGFloat(cos(roc)) + centreOfRing.x, y: largestRingRadius * CGFloat(sin(roc)) + centreOfRing.y)
    }
}
