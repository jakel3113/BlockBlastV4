//
//  GameViewController.swift
//  SoloMissionTutorial
//
//  Created by Jake Lonseth on 8/23/24.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
                
        super.viewDidLoad()
        
        //generates UserID if does not exist
        let defaults = UserDefaults.standard
        if(defaults.integer(forKey: "userID") == 0) {
            defaults.set(Int.random(in: 0...999999999), forKey: "userID")
        }
        
        if let view = self.view as! SKView? {
            let scene = GameScene(size: CGSize(width: 1536, height: 2048))
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
            
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

