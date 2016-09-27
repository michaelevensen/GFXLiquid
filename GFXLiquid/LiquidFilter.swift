//
//  LiquidFilter.swift
//  GFXLiquid
//
//  Created by Michael Nino Evensen on 24/09/2016.
//  Copyright © 2016 Michael Nino Evensen. All rights reserved.
//

import UIKit

class LiquidFilter: CIFilter {
    
    var inputImage: CIImage?

    // blur radius
    var blurRadius: CGFloat = 10.0

    // gradient color
    var gradientColor = UIColor.black // default
    
    // size
    var inputImageRect: CGRect? {
        guard let image = self.inputImage else {
            return nil
        }
        
        return image.extent
    }

    // computed threshold gradient (short, centered gradient)
    // note: the half clear / half colored gradient is what creates the threshold (hard edge)
    var gradient: CIFilter? {
        
        let hardEdgeThreshold: CGFloat = 10.0 // higher values = softer edges
        
        if let inputImageSize = self.inputImageRect?.size.width {
            let gradientStartVector = CIVector(x: inputImageSize/2, y: 0)
            let gradientEndVector = CIVector(x: gradientStartVector.x + hardEdgeThreshold, y: 0)
            
            // convert colors to CIColor
            let color = CIColor(color: self.gradientColor)
            
            // CISmoothLinearGradient
            let gradient = CIFilter(name: "CISmoothLinearGradient", withInputParameters: [
                "inputPoint0": gradientStartVector,
                "inputColor0": color,
                "inputPoint1": gradientEndVector,
                "inputColor1": CIColor(color: UIColor.clear)
                ])
            
            return gradient
        }
        
        return nil
    }
    
    // init
    public init(blurRadius: CGFloat, color: UIColor) {
        super.init()
        
        // set blur radius
        self.blurRadius = blurRadius
        
        // set color
        self.gradientColor = color
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // computed outputImage property
    override open var outputImage: CIImage? {
        guard let inputImage = self.inputImage else {
            return nil
        }
        
        // blur
        let blur = CIFilter(name: "CIGaussianBlur")
        blur?.setValue(inputImage, forKey: kCIInputImageKey)
        blur?.setValue(self.blurRadius, forKey: kCIInputRadiusKey)
        
        // fetch values
        guard let blurOutputImage = blur?.outputImage, let gradientOutputImage = self.gradient?.outputImage else {
            return nil
        }
        
        // increase gradient size to avoid blurry visible edges
        if let inputImageSize = self.inputImageRect {
            
            // external padding
//            let rectWithExternalPadding = CGRect(x: 0, y: 0, width: inputImageSize.size.width + 50, height: inputImageSize.size.height + 50)
            
            // crop gradient (or else gradient will be infinite, also required for CIColorMap)
            let gradientCroppedImage = gradientOutputImage.cropping(to: inputImageSize)
            
            // CIColorMap
            let map = CIFilter(name: "CIColorMap", withInputParameters: [
                "inputImage": blurOutputImage,
                "inputGradientImage": gradientCroppedImage
                ])
            
            return map?.outputImage
        }
        
        return nil
    }
}
