//
//  GameScene.swift
//  KLZombieConga
//
//  Created by 康梁 on 2017/4/24.
//  Copyright © 2017年 LeonKang. All rights reserved.
//

import SpriteKit

let animationKey = "animation"
let enemyName = "enemy"
let catName = "cat"

class GameScene: SKScene {
    
    let playableRect: CGRect
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let zombieMovePointPerSec: CGFloat = 488.0
    var velocity = CGPoint.zero
    var lastToucheLocation = CGPoint.zero
    let zombieAnimation: SKAction
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound:SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    
    // MARK: init
    override init(size: CGSize) {
        let maxAspectRadio: CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRadio
        let playableMargin = (size.height - playableHeight) / 2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        var textures: [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        #if DEBUG
            debugDrawPlayableArea()
        #endif
        
        backgroundColor = SKColor.black
        
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
        
        zombie.position = CGPoint(x: 400, y: 400)
        addChild(zombie)
        spawnEnemy()
        
        startZombieAnimation()
        self.run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run({
                self.spawnCat()
            }),
                               SKAction.wait(forDuration: 1.0)])))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        print("\(dt*1000) milliseconds since last update")

        moveSprite(sprite: zombie, velocity: velocity)
        boundsCheckZombie()
//        rotateSprite(sprite: zombie, direction: velocity)
        
        stopZombieAnimation()
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    // MARK: Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    func sceneTouched(touchLocation: CGPoint) {
        moveZombieToward(location: touchLocation)
        lastToucheLocation = touchLocation
    }
    
    // MARK: Zombie
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        let offset = CGPoint(x: location.x - zombie.position.x,
                             y: location.y - zombie.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = CGPoint(x: offset.x / CGFloat(length),
                                y: offset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * zombieMovePointPerSec,
                           y: direction.y * zombieMovePointPerSec)
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0,
                                 y: playableRect.minY)
        let topRight = CGPoint(x: size.width,
                               y: playableRect.maxY)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = .red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint) {
        sprite.zPosition = CGFloat(atan2(Double(direction.y),
                                         Double(direction.x)))
    }
    
    func startZombieAnimation() {
        if zombie.action(forKey: animationKey) == nil {
            zombie.run(
                SKAction.repeatForever(zombieAnimation),
                withKey: animationKey)
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeAction(forKey: animationKey)
    }
    
    // MARK: Enemy
    func spawnEnemy () {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = enemyName
        enemy.position = CGPoint(x: size.width + enemy.size.width / 2,
                                 y: CGFloat.random(min: playableRect.minY + enemy.size.height / 2,
                                                   max: playableRect.maxY - enemy.size.height / 2))
        addChild(enemy)
        
        let actionMove = SKAction.move(to: CGPoint(x: -enemy.size.width / 2, y: enemy.position.y), duration: 2.0)
        enemy.run(actionMove)
    }
    
    // MARK: Cats
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = catName
        cat.position = CGPoint(x: CGFloat.random(min: playableRect.minX, max: playableRect.maxX),
                               y: CGFloat.random(min: playableRect.minY, max: playableRect.maxY))
        cat.setScale(0)
        addChild(cat)
        
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        cat.zRotation = CGFloat(-Double.pi / 16.0)
        let leftWiggle = SKAction.rotate(byAngle: CGFloat(Double.pi/8), duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        
        let scaleUp = SKAction.scale(by: 1.3, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.run(SKAction.sequence(actions))
    }
    
    // MARK: Active
    func zombieHitCat(cat: SKSpriteNode) {
        cat.removeFromParent()
        run(catCollisionSound)
    }
    
    func zombieHitEnemy(enemy: SKSpriteNode) {
        enemy.removeFromParent()
        run(enemyCollisionSound)
    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []

        enumerateChildNodes(withName: catName) { (node, _) in
            let cat = node as! SKSpriteNode
            if cat.intersects(self.zombie) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHitCat(cat: cat)
        }
        
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: enemyName) { (node, _) in
            let enemy = node as! SKSpriteNode
            if enemy.intersects(self.zombie) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            zombieHitEnemy(enemy: enemy)
        }
    }
    
}
