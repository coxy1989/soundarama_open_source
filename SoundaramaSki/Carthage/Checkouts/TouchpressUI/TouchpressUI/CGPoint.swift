//
//  CGPoint.swift
//  TouchpressUI
//
//  Created by Jamie Cox on 21/02/2016.
//  Copyright © 2016 Touchpress. All rights reserved.
//

import CoreGraphics

extension CGPoint {
  
    /* 
        @param frame: The frame in which this point exists.
        @param scale: The scale at which the point is represented within the frame.
        @return: CGPoint where x and y are floating point numbers in the range (0...1).
    */
    
    public func normalize(frame: CGRect, scale: CGFloat) -> CGPoint {
        
        let w = frame.size.width * scale
        let h = frame.size.height * scale
        let x = self.x * scale / w
        let y = self.y * scale / h
        return CGPointMake(x, y)
    }
    

    public func denormalize(frame: CGRect, scale: CGFloat) -> CGPoint {
        
        let w = frame.size.width * scale
        let h = frame.size.height * scale
        let x = self.x * w / scale
        let y = self.y * h / scale
        return CGPointMake(x, y)
    }
}

extension CGPoint {
    
    public static func centroid(points: [CGPoint]) -> CGPoint {
        
        let x = points.reduce(0) { $0 + $1.x } / CGFloat(points.count)
        let y =  points.reduce(0) { $0 + $1.y } / CGFloat(points.count)
        return CGPointMake(x, y)
    }
    
    public func inRect(rect: CGRect) -> CGPoint {
        
        if !rect.contains(self) {
            
            var xx = x
            var yy = y
            
            if x < CGRectGetMinX(rect){
                xx = x + (CGRectGetMinX(rect) - x)
            }
                
            else if x > CGRectGetMaxX(rect) {
                xx = x - (x - CGRectGetMaxX(rect))
            }
            
            if y < CGRectGetMinY(rect) {
                yy = y + (CGRectGetMinY(rect) - y)
            }
            
            else if  y > CGRectGetMaxY(rect) {
                yy =  y - (y - CGRectGetMaxY(rect))
            }
        
            return CGPointMake(xx, yy)
            
        }
        
        return self
    }
    
    public func inRelativeCoordinateSpace(origin: CGPoint, size: CGSize) -> CGPoint {
        
        let conv_x = x + origin.x + (x * size.width)
        let conv_y = y + origin.y + (y * size.height)
        return CGPointMake(conv_x, conv_y)
    }
    
    public static func vogelSpiral(n: UInt) -> [CGPoint] {
        
        let golden = M_PI * (3 - sqrt(5))
        var points: [CGPoint] = []
        for i in 0..<Int(n) {
            let theta = Double(i) * golden
            let r = sqrt(Double(i)) / sqrt(Double(n))
            let x = CGFloat(r * cos(theta))
            let y = CGFloat(r * sin(theta))
            points.append(CGPointMake(x, y))
        }
        
        return points
    }
}