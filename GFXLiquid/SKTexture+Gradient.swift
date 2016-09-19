//
//  SKTexture+Gradient.swift
//  GFXLiquid
//
//  Created by Michael Nino Evensen on 19/09/16.
//  Copyright © 2016 Michael Nino Evensen. All rights reserved.
//
import Foundation
import SpriteKit
import UIKit

extension SKTexture {
    /* FIXME
     This code breaks on iOS 8 (reference post)
     http://stackoverflow.com/questions/19243111/spritekit-sktexture-crash/19248293#19248293
     */
    
    convenience init(rect: CGRect, firstColor: UIColor, lastColor: UIColor) {
        
        guard let gradientFilter = CIFilter(name: "CIRadialGradient") else {
            self.init()
            return
        }
        
//        guard let gradientFilter = CIFilter(name: "CILinearGradient") else {
//            self.init()
//            return
//        }
        
        gradientFilter.setDefaults()
        
//        let startVector = CIVector(x: size.width/2.0, y: 0)
//        let endVector = CIVector(x: size.width/2.0, y: size.height)
        
        let center = CIVector(x: rect.origin.x + rect.size.width/2.0, y: rect.origin.y + rect.size.height/2.0)
        
        gradientFilter.setValue(rect.size.width, forKey: "inputRadius0")
        gradientFilter.setValue(rect.size.height, forKey: "inputRadius1")
        gradientFilter.setValue(center, forKey: "inputCenter")
        
        
        
        
//        gradientFilter.setValue(startVector, forKey: "inputPoint0")
//        gradientFilter.setValue(endVector, forKey: "inputPoint1")
        
        let transformedFirstColor = CIColor(color: firstColor)
        let transformedLastColor = CIColor(color: lastColor)
        gradientFilter.setValue(transformedFirstColor, forKey: "inputColor1")
        gradientFilter.setValue(transformedLastColor, forKey: "inputColor0")
        
        guard let outputImage = gradientFilter.outputImage else {
            self.init()
            return
        }
        
        let context = CIContext()
        let image = context.createCGImage(outputImage, from: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        
        self.init(cgImage: image!)
    }
}
