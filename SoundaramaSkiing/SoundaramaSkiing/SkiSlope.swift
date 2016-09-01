//
//  SkiSlope.swift
//  SoundaramaSkiing
//
//  Created by Joseph Thomson on 14/07/2016.
//  Copyright © 2016 Touchpress. All rights reserved.
//

import Foundation

struct SkiSlope
{
    enum Generator
    {
        case Constant
        case TriangularMountains
        case SineWave
        
        var heights: [UInt8]
        {
            switch self
            {
            case .Constant:
                return [(UInt8.max - UInt8.min) / 2]
            case .SineWave:
                return [32, 44, 56, 68, 79, 91, 102, 113, 124, 134, 144, 154, 163, 171, 179, 187, 193, 199, 205, 210, 214, 217, 220, 221, 223, 223, 223, 221, 220, 217, 214, 210, 205, 199, 193, 187, 179, 171, 163, 154, 144, 134, 124, 113, 102, 91, 79, 68, 56, 44, 32]
            case .TriangularMountains:
                let adjustment: UInt8 = 4
                let maximum: UInt8 = 223
                let minimum: UInt8 = 31
                
                var heights = [minimum]
                var lastValue: UInt8 = minimum
                var ascending = true
                
                while lastValue > minimum || ascending == true
                {
                    if ascending
                    {
                        if maximum - adjustment >= lastValue
                        {
                            lastValue += adjustment
                            heights.append(lastValue)
                        }
                        else
                        {
                            ascending = false
                        }
                    }
                    else
                    {
                        if minimum + adjustment <= lastValue
                        {
                            lastValue -= adjustment
                            heights.append(lastValue)
                        }
                        else
                        {
                            lastValue = minimum
                            heights.append(lastValue)
                        }
                    }
                }
                return heights
            }
        }
    }
    
    private var heights: [UInt8]
    private var repeats: Bool
    
    init(heights: [UInt8], repeats: Bool = true)
    {
        self.heights = heights
        self.repeats = repeats
    }
    
    init(generator: SkiSlope.Generator, repeats: Bool = true)
    {
        self.heights = generator.heights
        self.repeats = repeats
    }
    
    func heightForBlock(blockIndex: Int) -> UInt8
    {
        if self.heights.count > blockIndex
        {
            return self.heights[blockIndex]
        }
        else if self.repeats
        {
            return self.heights[blockIndex % self.heights.count]
        }
        else
        {
            return 0
        }
    }
}
