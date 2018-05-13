//
//  GameOverScene.swift
//  TwoKars
//
//  Created by digvijay.s on 13/05/18.
//  Copyright © 2018 digvijay.s. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    init(size: CGSize, score: Int) {
        super.init(size: size)
        
        backgroundColor = SKColor.white
        let message = "Score: \(score)"
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
