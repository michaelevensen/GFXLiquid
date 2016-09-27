//
//  ViewController.swift
//  Væske
//
//  Created by Michael Nino Evensen on 16/09/16.
//  Copyright (c) 2016 Michael Nino Evensen. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    let skView = SKView()
    let scene = SKScene()
    
    let wall: UInt32 = 0x1
    let ball: UInt32 = 0x1 << 1
    
    let radialGravity = SKFieldNode.radialGravityField()
    let dragField = SKFieldNode.dragField()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // This seemed like the best option
        self.scene.scaleMode = .resizeFill
    
        // AFAIK this is the "same" as addSubview()
        self.skView.presentScene(self.scene)
        self.scene.backgroundColor = UIColor.white
        
        // add view
        self.view.addSubview(skView)
        
        // create walls
        self.scene.physicsBody = SKPhysicsBody(edgeLoopFrom: self.view.frame)
        
        // make nodes
        self.makeNodes()
    
        // add filter
        let filterColor = UIColor(red: 0.00, green: 0.34, blue: 0.93, alpha: 1.0)
        self.scene.shouldEnableEffects = true
        self.scene.filter = LiquidFilter(blurRadius: 16, color: filterColor)
        
        // 0.0, -9.8 correspond with Earth's gravity.
        self.scene.physicsWorld.gravity = CGVector.zero
        
        self.radialGravity.strength = 0.5
        self.dragField.strength = 1.0
        
        // initial position
        self.radialGravity.falloff = 1.0
        self.radialGravity.region = SKRegion(radius: 500)
        self.radialGravity.position = self.view.center
        
        // add field nodes
        self.scene.addChild(self.radialGravity)
        self.scene.addChild(self.dragField)
    }
    
    func makeNodes() {
        // create nodes
        for _ in 0..<100 {
            let radius = arc4random_uniform(30) + 10 // from 10 to 20 (shouldn't be smaller than 10 to achieve liquid shape)
            self.scene.addChild(self.addShapeNode(withRadius: CGFloat(radius)))
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.skView.frame = self.view.frame
    }
    
    private func addShapeNode(withRadius radius: CGFloat) -> SKShapeNode {
        
        let node = SKShapeNode(circleOfRadius: radius)
        
        // random positioning
        node.position = CGPoint(x: CGFloat(drand48()) * self.view.frame.width, y: CGFloat(drand48()) * self.view.frame.height)
        
        // node properties
        node.fillColor = UIColor.black // this has to be in contrast to the background
        node.strokeColor = node.fillColor
        
        /*
        *   Node Physics Body
        */
        if let path = node.path {
            
            // How much energy do we want the body to lose on a collision? 1.0 means all. The default is 0.2.
            let physics = SKPhysicsBody(polygonFrom: path)
            physics.restitution = 0.25

            // add body
            node.physicsBody = physics
            
            if let body = node.physicsBody {
                // I wasn't sure if this was needed.
                body.mass = 1.0
                
                // Here we set the category.
                body.categoryBitMask = self.ball
                
                // The ball should collide with the walls!
                body.collisionBitMask = self.wall
                
                // And yes actually do something, I think..
                body.contactTestBitMask = self.wall
            }
            
            // physics
            let radial = SKFieldNode.radialGravityField()
            
            radial.strength = 0.015
            radial.falloff = 0.5
            radial.region = SKRegion(radius: 5)
            
            node.addChild(radial)
        }
        
        return node
    }
    
    func getPhysicsBody(ofSize size: CGSize) -> SKPhysicsBody {
        
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        
        // The walls should never lose energy on a collision.
        body.restitution = 0
        
        // Difference of category
        body.categoryBitMask = self.wall
        
        // Should collide with the balls
        body.collisionBitMask = self.ball
        
        // Should detect contact.
        body.contactTestBitMask = self.ball
        
        return body
    }
    
    // radial gravity strength
    @IBAction func adjustRadialGravity(_ sender: UISlider) {
        self.radialGravity.strength = min(max(sender.value, 1), 0)
    }
    // dragfield strength
    @IBAction func adjustDragfieldStrength(_ sender: UISlider) {
    }
    
    // radial gravity falloff
    @IBAction func adjustRadialGravityFalloff(_ sender: UISlider) {
    }
    
    // body restitution
    @IBAction func adjustBodyRestitution(_ sender: UISlider) {
    }
}

extension ViewController {
    
    // set gravity based on force touch
    func setGravity(forTouch touch: UITouch) {
        
        // append force touch strength
        self.radialGravity.strength = (traitCollection.forceTouchCapability == UIForceTouchCapability.available) ? Float(touch.force / touch.maximumPossibleForce) * 6 : 3
        
        // move position
        self.radialGravity.position = CGPoint(x: touch.location(in: self.skView).x, y: view.frame.height-touch.location(in: self.skView).y)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        setGravity(forTouch: touches.first!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        setGravity(forTouch: touches.first!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Return to normal, once we've crossed the event horizon.
        self.radialGravity.strength = 0.5
    }
}

