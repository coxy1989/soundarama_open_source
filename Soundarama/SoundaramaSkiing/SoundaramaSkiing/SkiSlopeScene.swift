//
//  SkiSlopeScene.swift
//  SoundaramaSkiing
//
//  Created by Joseph Thomson on 14/07/2016.
//  Copyright © 2016 Touchpress. All rights reserved.
//

import SpriteKit

protocol SkiSlopeSceneDelegate: class
{
    func skiSlopeScene(scene: SkiSlopeScene, didChangeScore score: Int)
}

class SkiSlopeScene: SKScene
{
    weak var skiSlopeDelegate: SkiSlopeSceneDelegate?
    
    private var score: Int = 0
    {
        didSet
        {
            self.skiSlopeDelegate?.skiSlopeScene(self, didChangeScore: self.score)
        }
    }
    private var missedDotsInARow: Int = 0
    
    private let slope: SkiSlope
    private let player: SKSpriteNode
    
    private var slopeBlocks = [Int: SKShapeNode]()
    private var slopeDots = [Int: SKShapeNode]()
    private var collectedDots = Set<Int>()
    
//    private static let instrument = "Synth"
    private static let instrument = "Drums"
    private let audio = AudioController(goodFile: "\(instrument)_Good", badFile: "\(instrument)_Bad")!
    
    init(slope: SkiSlope)
    {
        self.slope = slope
        self.player = SKSpriteNode(imageNamed: "Player")
        
        super.init(size: UIScreen.mainScreen().bounds.size)
        
        self.backgroundColor = UIColor(red: 217/255, green: 104/255, blue: 87/255, alpha: 1.0)
        
        self.player.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width)
        self.player.physicsBody?.linearDamping = 0
        self.player.zPosition = 100
        self.player.position = self.size.center
        self.player.runAction(SKAction.applyForce(CGVector(dx: 12222, dy: 0), duration: 0.2))
        self.player.constraints = [ SKConstraint.positionY( SKRange(lowerLimit: self.player.size.center.y) ) ]
        self.addChild(self.player)
        
        let playerCamera = SKCameraNode()
        playerCamera.position = self.player.position
        playerCamera.constraints = [ SKConstraint.distance(SKRange(constantValue: 0), toNode: self.player),
                                     SKConstraint.positionY(SKRange(constantValue: self.size.center.y)),
                                    ]
        self.addChild(playerCamera)
        self.camera = playerCamera
        
        self.audio.play()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        let visibleRect = CGRect(x: self.player.position.x - self.size.center.x, y: -self.size.center.y, size: UIScreen.mainScreen().bounds.size)
        self.drawSkiSlopeForRect(visibleRect)
        
        self.physicsWorld.gravity = self.currentTouches > 0 ? CGVector(dx: 0.0, dy: 0.98) : CGVector(dx: 0.0, dy: -1.22)
        
        let badAmmount = Float(self.missedDotsInARow) / 2
        self.audio.badAmmount = badAmmount
    }
    
    private func drawSkiSlopeForRect(rect: CGRect)
    {
        let blockWidth: CGFloat = 15
        let blockPaddingX: CGFloat = 15
        let blockWidthPlusPadding = blockWidth + blockPaddingX
        let firstBlockIndex = Int(floor(rect.origin.x / blockWidthPlusPadding))
        let lastBlockIndex = firstBlockIndex + Int(ceil(rect.width / blockWidthPlusPadding))
        
        for currentBlockIndex in firstBlockIndex...lastBlockIndex
        {
            if self.slopeDots[currentBlockIndex] == nil && self.collectedDots.contains(currentBlockIndex) == false
            {
                let dotX = CGFloat(currentBlockIndex) * (blockWidth + blockPaddingX)
                let dotY = CGFloat(self.slope.heightForBlock(currentBlockIndex)) * (self.size.height / CGFloat(UInt8.max))
                
                let dotRect = CGRect(x: dotX, y: self.size.height - dotY, width: blockWidth, height: blockWidth)
                let dot = SKShapeNode(ellipseInRect: dotRect)
                dot.zPosition = 1
                dot.lineWidth = 0
                dot.fillColor = UIColor(red: 250/255, green: 200/255, blue: 200/255, alpha: 1.0)
                self.addChild(dot)
                self.slopeDots[currentBlockIndex] = dot
            }
            
            if let slopeDot = self.slopeDots[currentBlockIndex] where self.collectedDots.contains(currentBlockIndex) == false
            {
                if slopeDot.intersectsNode(self.player)
                {
                    self.collectedDots.insert(currentBlockIndex)
                    slopeDot.removeFromParent()
                    self.slopeDots[currentBlockIndex] = nil
                    
//                    self.score += 1
                    self.missedDotsInARow = 0
                    self.backgroundColor = UIColor(red: 217/255, green: 104/255, blue: 87/255, alpha: 1.0)
                    
                    if self.slopeBlocks[currentBlockIndex] == nil
                    {
                        let blockX = CGFloat(currentBlockIndex) * (blockWidth + blockPaddingX)
                        let blockY = CGFloat(self.slope.heightForBlock(currentBlockIndex)) * (self.size.height / CGFloat(UInt8.max))
                        let blockHeight = self.size.height - blockY
                        
                        let blockRect = CGRect(x: blockX, y: 0, width: blockWidth, height: blockHeight)
                        let block = SKShapeNode(rect: blockRect)
                        block.zPosition = 1
                        block.lineWidth = 0
                        block.fillColor = UIColor(white: 0.9, alpha: 1.0)
                        self.addChild(block)
                        self.slopeBlocks[currentBlockIndex] = block
                    }
                }
                else if slopeDot.frame.maxX < self.player.frame.midX
                {
//                    self.score -= 1
                    self.missedDotsInARow += 1
                    self.backgroundColor = UIColor(red: 180/255, green: 88/255, blue: 72/255, alpha: 1.0)
                    slopeDot.alpha = 0.5
                    self.collectedDots.insert(currentBlockIndex)
                }
            }
        }
    }
    
    
    private var currentTouches: Int = 0
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        currentTouches += 1
        if currentTouches == 1
        {
            self.player.runAction( SKAction.applyImpulse(CGVector(dx: 0, dy: 6000), duration: 0.25) )
            if self.player.position.y == self.player.size.center.y
            {
                self.player.physicsBody?.velocity.dy = -100
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        currentTouches -= 1
        if currentTouches == 0
        {
            self.player.runAction( SKAction.applyImpulse(CGVector(dx: 0, dy: -6000), duration: 0.25) )
        }
    }
}

extension CGSize
{
    var center: CGPoint
    {
        return CGPoint(x: self.width / 2, y: self.height / 2)
    }
}

extension CGRect
{
    init(x: CGFloat, y: CGFloat, size: CGSize)
    {
        self.init(x: x, y: y, width: size.width, height: size.height)
    }
}
