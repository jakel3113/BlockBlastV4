//
//  GameOverScene.swift
//  BlockBlastGit
//
//  Created by Jake Lonseth on 10/30/24.
//

import SpriteKit
import GameplayKit

class GameOverScene: SKScene {
    
    var score: Int
    var highScore: Int
    var playAgainRect = CGRect()
    var savedData: [[String: Any]]
    
    init(size: CGSize, score: Int, highScore: Int, savedData: [[String: Any]]) {
        
        self.score = score
        self.highScore = highScore
        self.savedData = savedData
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        //upload all data to Firebase
        let storageManager = StorageManager()
        let defaults = UserDefaults.standard
        var currentIteration = defaults.integer(forKey: "currentIteration")
        
        for dataDict in savedData {
            currentIteration += 1
            storageManager.uploadData(finalScore: score, currentScore: dataDict["currentScore"] as! Int, gridStatus: dataDict["gridStatus"] as! [Bool], pointingArrIndexes: dataDict["pointingArrIndexes"] as! [Int], blockRotations: dataDict["blockRotations"] as! [Int], currentIteration: currentIteration, userID: defaults.integer(forKey: "userID"))
        }
        
        defaults.set(currentIteration, forKey: "currentIteration")
        
        //create UI
        let startPoint = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + 500)
        var labelArr = [SKLabelNode]()
        let textArr = [("Game Over!", 100), ("Score", 50), (String(score), 120), ("High Score", 50), (String(highScore), 120)]
        
        for index in 0...textArr.count {
            
            if(index != textArr.count) {
                labelArr.append(SKLabelNode(fontNamed: "Chalkduster"))
                labelArr[index].text = textArr[index].0
                labelArr[index].fontSize = CGFloat(textArr[index].1)
                labelArr[index].horizontalAlignmentMode = .center
                labelArr[index].position = CGPoint(x: startPoint.x, y: startPoint.y - 100 * CGFloat(index))
                
                self.addChild(labelArr[index])
            } else {
                playAgainRect = CGRect(x: startPoint.x - 250, y: startPoint.y - 150 * CGFloat(index) - 100, width: 500, height: 200)
                /*let playAgainNode = SKShapeNode(rect: playAgainRect)
                playAgainNode.fillColor = UIColor.green
                playAgainNode.zPosition = 1
                playAgainNode.strokeColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
                playAgainNode.lineWidth = 10
                self.addChild(playAgainNode)*/
                
                let point1 = CGPoint(x: startPoint.x - (75 * tan(Double.pi / 3)) / 2, y: playAgainRect.minY + playAgainRect.height / 2 + 75)
                let point2 = CGPoint(x: point1.x, y: point1.y - 150)
                let point3 = CGPoint(x: startPoint.x + (75 * tan(Double.pi / 3)) / 2, y: point2.y + 75)
                
                let path = UIBezierPath()
                path.move(to: point1)
                path.addLine(to: point2)
                path.addLine(to: point3)
                path.addLine(to: point1)
                
                let triangle = SKShapeNode(path: path.cgPath)
                triangle.zPosition = 2
                triangle.lineWidth = 10
                triangle.strokeColor = UIColor.white
                self.addChild(triangle)
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let touchLocation = touch.location(in: self)
                
            if(touchLocation.y > playAgainRect.minY && touchLocation.y < playAgainRect.minY + playAgainRect.height && touchLocation.x > playAgainRect.minX && touchLocation.x < playAgainRect.minX + playAgainRect.width) {
                
                if let view = self.view {
                    // Load the SKScene from 'GameScene.sks'
                    let scene = GameScene(size: CGSize(width: 1536, height: 2048))
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFill
                    
                    // Present the scene
                    view.presentScene(scene)
                }
                
            }
            
        }
    }
}
