//
//  MetaMetaball.swift
//  Væske
//
//  Created by Michael Nino Evensen on 16/09/16.
//  Copyright © 2016 Michael Nino Evensen. All rights reserved.
//

import UIKit

class MetaBallFilter: CIFilter {

    var inputImage: CIImage?
    let gradient = CIImage(image: UIImage(named: "gradient_overlay.png")!)!
    
    override var outputImage: CIImage? {
        guard let inputImage = inputImage else { return nil	}
        
        let blur = CIFilter(name: "CIGaussianBlur")!
        let map = CIFilter(name: "CIColorMap")!
        
        // note: radius has to be half of the node size for this effect to work
        let radius = 20
        blur.setValue(radius, forKey: kCIInputRadiusKey)
        blur.setValue(inputImage, forKey: kCIInputImageKey)
        
        // Change the _gradient image itself_ to change the blob shape.
        map.setValue(blur.outputImage, forKey: kCIInputImageKey)
        map.setValue(self.gradient, forKey: kCIInputGradientImageKey)
        return map.outputImage
    }
}
