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
        self.skView.backgroundColor = UIColor.black
        
        // add view
        self.view.addSubview(skView)
        
        // create walls
        self.createWalls()
        
        // add node(s)
        for _ in 0..<50 {
            self.scene.addChild(self.addShapeNode(withRadius: 42))
        }
       
        self.scene.filter = MetaBallFilter()
        self.scene.shouldEnableEffects = true
        
        // 0.0, -9.8 correspond with Earth's gravity.
        self.scene.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        self.radialGravity.strength = 0.5
        self.dragField.strength = 0.8
        
        // add field nodes
        self.scene.addChild(self.radialGravity)
        self.scene.addChild(self.dragField)
    }
    
    override func viewDidLayoutSubviews() {
        self.skView.frame = self.view.frame
    }
    
    private func addShapeNode(withRadius radius: CGFloat) -> SKShapeNode {
        
        let node = SKShapeNode(circleOfRadius: radius)
        
        // random positioning
        node.position = CGPoint(x: CGFloat(drand48()) * self.view.frame.width, y: CGFloat(drand48()) * self.view.frame.height)
        
        // node properties
        node.fillColor = UIColor.cyan
        node.strokeColor = node.fillColor
       
        /*
        *   Node Physics Body
        */
        if let path = node.path {
            
            // How much energy do we want the body to lose on a collision? 1.0 means all. The default is 0.2.
            let physics = SKPhysicsBody(polygonFrom: path)
            physics.restitution = 1

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
    
    func createWalls() {
        let left = SKShapeNode(rectOf: CGSize(width: 2, height: view.frame.height))
        left.position = CGPoint(x: 2, y: view.frame.height / 2)
        left.physicsBody = getPhysicsBody(ofSize: CGSize(width: 2, height: view.frame.height))
        self.scene.addChild(left)
        
        let right = SKShapeNode(rectOf: CGSize(width: 2, height: view.frame.height))
        right.position = CGPoint(x: view.frame.width-2, y: view.frame.height / 2)
        right.physicsBody = getPhysicsBody(ofSize: CGSize(width: 2, height: view.frame.height))
        self.scene.addChild(right)
        
        let floor = SKShapeNode(rectOf: CGSize(width: view.frame.width, height: 2))
        floor.position = CGPoint(x: view.frame.width / 2, y: 2)
        floor.physicsBody = getPhysicsBody(ofSize: CGSize(width: view.frame.width, height: 2))
        self.scene.addChild(floor)
        
        let roof = SKShapeNode(rectOf: CGSize(width: view.frame.width, height: 2))
        roof.position = CGPoint(x: view.frame.width / 2, y: view.frame.height - 2)
        roof.physicsBody = getPhysicsBody(ofSize: CGSize(width: view.frame.width, height: 2))
        self.scene.addChild(roof)
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
}

extension ViewController {
    
    
    // set gravity based on force touch
    func setGravity(forTouch touch: UITouch) {
        
        
        self.radialGravity.falloff = 1.0
        self.radialGravity.region = SKRegion(radius: 568)
        self.radialGravity.strength = (traitCollection.forceTouchCapability == UIForceTouchCapability.available) ? Float(touch.force / touch.maximumPossibleForce) * 6 : 3
        
        //
        self.radialGravity.position = CGPoint(x: touch.location(in: skView).x, y: view.frame.height-touch.location(in: skView).y)
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

/* UIColor Extension */
extension UIColor {
    func rand() -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
    }
}
