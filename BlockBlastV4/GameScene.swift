//
//  GameScene.swift
//  SoloMissionTutorial
//
//  Created by Jake Lonseth on 8/23/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let gameArea: CGRect
    let margin: CGFloat
    let squareSideLength: CGFloat
    let blockZone1: BlockZone
    let blockZone2: BlockZone
    let blockZone3: BlockZone
    var activePiece: (GamePiece?, Int)
    var savedPoint: CGPoint
    var suggestedPosition: CGPoint
    var gridInformation: GridInformation
    var shadowArr = [SKShapeNode]()
    var blocksOnGrid = [SKShapeNode]()
    var blocksOnGridPositions = [(Int, Int)]()
    var score = 0
    var combo = 0
    let scoreValueLabel = SKLabelNode(fontNamed: "Chalkduster")
    var newPieces: [GamePiece?] = [nil, nil, nil]
    var clearBlockIndicator = [SKShapeNode]()
    let defaults = UserDefaults.standard
    var savedData: [[String: Any]] = []
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 22.0/9.0
        let playableWidth = size.height / maxAspectRatio
        margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        squareSideLength = gameArea.width * 9 / 10
        
        blockZone3 = BlockZone(rect: CGRect(x: margin + gameArea.width / 3 * 2, y: 0, width: gameArea.width / 3, height: gameArea.height / 12 * 5))
        blockZone2 = BlockZone(rect: CGRect(x: margin + gameArea.width / 3, y: 0, width: gameArea.width / 3, height: gameArea.height / 12 * 5))
        blockZone1 = BlockZone(rect: CGRect(x: margin, y: 0, width: gameArea.width / 3, height: gameArea.height / 12 * 5))
        
        activePiece = (nil, 0)
        savedPoint = CGPoint(x: 0, y: 0)
        suggestedPosition = CGPoint(x: 0, y: 0)
        
        gridInformation = GridInformation()
        
        super.init(size: size)
        
    }
    
    class BlockZone {
        var rect: CGRect
        var piece: GamePiece?
        
        init(rect: CGRect) {
            self.rect = rect
            piece = nil
        }
        
        func isEqual(comparing: BlockZone) -> Bool {
            if(rect == comparing.rect) {
                return true
            } else {
                return false
            }
        }
    }
    
    class GridInformation {
        var gridArr: [UIColor?]
        
        init() {
            gridArr = [UIColor?]()
            for _ in 1...64 {
                gridArr.append(nil)
            }
        }
        
        func getColor(row: Int, col: Int) -> UIColor? {
            return gridArr[row * 8 + col]
        }
        
        func setColor(row: Int, col: Int, color: UIColor?) {
            gridArr[row * 8 + col] = color
        }
        
        func getRowCol(index: Int) -> (Int, Int) {
            let row = Int(index / 8)
            let col = index % 8
            return (row, col)
        }
        
        func canFit(piece: GamePiece) -> Bool {
            
            var doesFit: Bool
            
            //loops through every gridPoint
            for startPoint in 0...gridArr.count-1 {
                
                var rowCol = getRowCol(index: startPoint)
                
                //if start point is empty
                if(gridArr[startPoint] == nil) {
                    
                    doesFit = true
                    
                    for pointer in piece.pointingArr {
                        
                        //deciphers pointer
                            if(pointer == 0) {
                                rowCol.1 -= 1
                            } else if(pointer == 1) {
                                rowCol.0 += 1
                            } else if(pointer == 2) {
                                rowCol.1 += 1
                            } else if(pointer == 3) {
                                rowCol.0 -= 1
                            }
                        
                        if(rowCol.0 < 0 || rowCol.0 > 7 || rowCol.1 < 0 || rowCol.1 > 7 || getColor(row: rowCol.0, col: rowCol.1) != nil) {
                            
                            doesFit = false
                            break
                            
                        }
                        
                    }
                    
                    if(doesFit) {
                        return true
                    }
                    
                }
                
            }
            
            return false
            
        }
    }
    
    class GamePiece {
        var color: UIColor
        var startBlockZone: BlockZone
        //0 left; 1 up; 2 right; 3 down
        var pointingArr: [Int]
        var scaleFactor: CGFloat
        var blocks: [SKShapeNode]
        var dominantSize: CGFloat
        
        init(color: UIColor, pointingArr: [Int], startBlockZone: BlockZone) {
            self.color = color
            self.startBlockZone = startBlockZone
            scaleFactor = CGFloat(1)
            blocks = []
            dominantSize = 0
            self.pointingArr = pointingArr
        }
        
    }
    
    func getMax(val1: CGFloat, val2: CGFloat) -> Float {
        
        if(val1 > val2) {
            return Float(val1)
        } else {
            return Float(val2)
        }
        
    }
    
    func generateRandomColor() -> UIColor {
        
        let red = CGFloat(Float.random(in: 0.5...1))
        let green = CGFloat(Float.random(in: 0.5...1))
        let blue = CGFloat(Float.random(in: 0...getMax(val1: green, val2: red)))
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
        
    }
    
    func updateScore(changeInScore: Int) {
        self.scoreValueLabel.text = String(self.score)
        let randomColor = generateRandomColor()
        
        let grow = SKAction.scale(by: 5/4, duration: 0.2)
        let colorize = SKAction.colorize(with: randomColor, colorBlendFactor: 1, duration: 0.2)
        let shrink = SKAction.scale(by: 4/5, duration: 0.2)
        let fade = SKAction.fadeAlpha(to: 0, duration: 0.2)
        let delete = SKAction.removeFromParent()
        
        let firstSequence = SKAction.sequence([grow, colorize])
        let secondSequence = SKAction.sequence([grow, fade, delete])
        
        let tempLabel = SKLabelNode(fontNamed: "Chalkduster")
        tempLabel.text = String(score)
        tempLabel.fontSize = 62
        tempLabel.fontColor = scoreValueLabel.fontColor
        tempLabel.position = CGPoint(x: self.size.width / 2 + 200, y: 1850)
        tempLabel.zPosition = 5
        self.addChild(tempLabel)
        
        //show change in score
        let scoreChangeLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreChangeLabel.text = "+" + String(changeInScore)
        scoreChangeLabel.fontSize = 50
        scoreChangeLabel.position = CGPoint(x: self.size.width / 3 * 2, y: gameArea.height * 5 / 12 + 75)
        scoreChangeLabel.fontColor = randomColor
        scoreChangeLabel.zPosition = 6
        self.addChild(scoreChangeLabel)
        
        //show combo
        let comboLabel = SKLabelNode(fontNamed: "Chalkduster")
        if(combo > 1) {
            comboLabel.text = "Combo X" + String(combo)
            comboLabel.fontSize = 50
            comboLabel.position = CGPoint(x: self.size.width / 3, y: gameArea.height * 5 / 12 + 75)
            comboLabel.fontColor = randomColor
            comboLabel.zPosition = 6
            self.addChild(comboLabel)
        }
        
        //grow and change color
        tempLabel.run(firstSequence)
        scoreValueLabel.run(firstSequence, completion: {
            
            //shrink back and fade
            self.scoreValueLabel.run(shrink)
            tempLabel.run(secondSequence)
            scoreChangeLabel.run(secondSequence)
            comboLabel.run(secondSequence)
            
        })
        
    }
    
    func getPositionOfGridSquare(row: Int, col: Int) -> CGPoint {
        let increment = squareSideLength / 8
        let x1 = squareSideLength / 18 + margin
        let y1 = gameArea.height / 2
        let xVal = x1 + increment * CGFloat(col)
        let yVal = y1 + increment * CGFloat(row)
        let returnPoint = CGPoint(x: xVal, y: yVal)
        return returnPoint
    }
    
    func whichZonePiece(touch: CGPoint) -> (GamePiece?, Int) {
        if(touch.y < gameArea.height / 12 * 5) {
            if(touch.x < margin + gameArea.width / 3) {
                return (blockZone1.piece, 0)
            } else if(touch.x < margin + gameArea.width / 3 * 2) {
                return (blockZone2.piece, 1)
            } else {
                return (blockZone3.piece, 2)
            }
        }
        return (nil, 0)
    }
    
    func snapToPosition(inputPoint: CGPoint, pointingArr: [Int]) -> (CGPoint, Bool, Int, Int, [Int], [Int]) {
        
        var closestSquare = CGPoint(x: 0, y: 0)
        var openSquare = false
        var positionTuple = (0, 0)
        var toBeFilled = [(Int, Int, Int)]()
        
        for index in 0...63 {
            positionTuple = gridInformation.getRowCol(index: index)
            
            //checks if close to square
            closestSquare = getPositionOfGridSquare(row: positionTuple.0, col: positionTuple.1)
            
            if(abs(inputPoint.x - closestSquare.x) < squareSideLength / 16 && abs(inputPoint.y - closestSquare.y) < squareSideLength / 16) {
                openSquare = true
                break
            }
            
        }
            
        //finds if it is filled
        if(openSquare && gridInformation.getColor(row: positionTuple.0, col: positionTuple.1) == nil) {

            //checks if neighbor points are filled
            var checkingRow = positionTuple.0
            var checkingCol = positionTuple.1
            
            toBeFilled.append((checkingRow, checkingCol, 0))
            
            for pointIndex in 0...pointingArr.count-1 {
                //points to next block
                if(pointingArr[pointIndex] == 0) {
                    checkingCol -= 1
                } else if(pointingArr[pointIndex] == 1) {
                    checkingRow += 1
                } else if(pointingArr[pointIndex] == 2) {
                    checkingCol += 1
                } else if(pointingArr[pointIndex] == 3) {
                    checkingRow -= 1
                }
                
                //checks if next block is open
                if(checkingRow >= 0 && checkingRow < 8 && checkingCol >= 0 && checkingCol < 8) {
                    if(gridInformation.getColor(row: checkingRow, col: checkingCol) != nil) {
                        
                        openSquare = false
                        toBeFilled = []
                        
                    } else {
                        
                        toBeFilled.append((checkingRow, checkingCol, pointIndex + 1))
                        
                    }
                } else {
                    openSquare = false
                    toBeFilled = []
                }
            }
        } else {
            openSquare = false
            toBeFilled = []
        }
        
        if(openSquare) {
            
            //checks if rows are filled
            var filledRows = [Int]()
            
            for row in 0...7 {
                
                var isFull = true
                
                //looks for points in the relevant row
                var filledColumnPoints = [Int]()
                for index in 0...toBeFilled.count - 1 {
                    if(row == toBeFilled[index].0) {
                        filledColumnPoints.append(toBeFilled[index].1)
                    }
                }
                
                //checks if entire line is cleared
                for col in 0...7 {
                    if(!filledColumnPoints.contains(col) && gridInformation.gridArr[row * 8 + col] == nil) {
                        isFull = false
                        break
                    }
                }
                
                if(isFull) {
                    filledRows.append(row)
                }
                
            }
            
            //checks if cols are filled
            var filledCols = [Int]()
            for col in 0...7 {
                
                var isFull = true
                
                //looks for points in the relevant row
                var filledRowPoints = [Int]()
                for index in 0...toBeFilled.count - 1 {
                    if(col == toBeFilled[index].1) {
                        filledRowPoints.append(toBeFilled[index].0)
                    }
                }
                
                //checks if entire line is cleared
                for row in 0...7 {
                    if(!filledRowPoints.contains(row) && gridInformation.gridArr[row * 8 + col] == nil) {
                        isFull = false
                        break
                    }
                }
                
                if(isFull) {
                    filledCols.append(col)
                }
                
            }
            
            return (closestSquare, true, positionTuple.0, positionTuple.1, filledRows, filledCols)
            
        } else {
            
            return (inputPoint, false, 0, 0, [], [])
            
        }
        
    }
    
    func getPointingArr() -> ([Int], Int, Int) {
        
        //all pointing arrs
        let pointingArrArr = [
            [1, 1, 1, 1],
            [1, 1, 1],
            [1, 2, 3],
            [1, 1, 2, 2, 3, 3, 0, 1],
            [1, 1, 2, 3, 3],
            [0, 1, 1],
            [2, 1, 1],
            [1, 2, 1],
            [1, 0, 1],
            [0, 1, 3, 3]
        ]
        
        //random arr and random rotation
        let randomArr = Int.random(in: 0...pointingArrArr.count-1)
        var chosenArr = pointingArrArr[randomArr]
        let randomRotation = Int.random(in: 0...3)
        let rotation = randomRotation
        
        //rotates based on rr
        for index in 0...chosenArr.count-1 {
            chosenArr[index] = (chosenArr[index] + rotation) % 4
        }
        
        return (chosenArr, randomArr, randomRotation)
    }
    
    func getFromPointers(pointingArr: [Int]) -> ((Int, Int), (Int, Int)) {
        
        //width x height
        var gridDimensions = (1, 1)
        //x, y
        var currentLocation = (0, 0)
        
        var lowBound = 0
        var leftBound = 0
        
        for pointer in pointingArr {
            
            //moves current location
            if(pointer == 0){
                currentLocation.1 -= 1
            } else if(pointer == 1) {
                currentLocation.0 += 1
            } else if(pointer == 2) {
                currentLocation.1 += 1
            } else {
                currentLocation.0 -= 1
            }
            
            //adjusts grid dimensions and bounds
            if(currentLocation.0 < lowBound) {
                lowBound -= 1
            } else if(currentLocation.0 > gridDimensions.1 - 1) {
                gridDimensions.1 += 1
            } else if(currentLocation.1 < leftBound) {
                leftBound -= 1
            } else if(currentLocation.1 > gridDimensions.0 - 1) {
                gridDimensions.0 += 1
            }
            
        }
        
        //resetting coordinate plane
        let originalLocation = (-leftBound, -lowBound)
        gridDimensions.0 -= leftBound
        gridDimensions.1 -= lowBound
        
        return (originalLocation, gridDimensions)
    }
    
    func addNewPieces() {
        newPieces = []
        var pointingArrIndexes = [Int]()
        var rotationNums  = [Int]()

        //makes sure first piece can fit
        var pointingData = getPointingArr()
        var tempPiece = GamePiece(color: UIColor.red,  pointingArr: pointingData.0, startBlockZone: blockZone1)
        
        for _ in 0...5 {
            if(gridInformation.canFit(piece: tempPiece)) {
                //use if fits
                break
            } else {
                //generate new if not
                pointingData = getPointingArr()
                tempPiece = GamePiece(color: UIColor.red,  pointingArr: pointingData.0, startBlockZone: blockZone1)
            }
        }
        
        //save block data
        pointingArrIndexes.append(pointingData.1)
        rotationNums.append(pointingData.2)
        newPieces.append(tempPiece)
        blockZone1.piece = newPieces[0]
        
        //adds other pieces
        pointingData = getPointingArr()
        pointingArrIndexes.append(pointingData.1)
        rotationNums.append(pointingData.2)
        newPieces.append(GamePiece(color: UIColor.blue, pointingArr: pointingData.0, startBlockZone: blockZone2))
        blockZone2.piece = newPieces[1]
        
        pointingData = getPointingArr()
        pointingArrIndexes.append(pointingData.1)
        rotationNums.append(pointingData.2)
        newPieces.append(GamePiece(color: UIColor.yellow, pointingArr: pointingData.0, startBlockZone: blockZone3))
        blockZone3.piece = newPieces[2]
        
        //create Bool gridArr
        var boolGridArr = Array.init(repeating: false, count: 64)
        for index in 0...boolGridArr.count-1 {
            if(gridInformation.gridArr[index] != nil) {
                boolGridArr[index] = true
            }
        }
        
        //update savedData
        savedData.append(["currentScore": score, "gridStatus": boolGridArr, "pointingArrIndexes": pointingArrIndexes, "blockRotations": rotationNums])
        
        
        for index in 0...2 {
            let piece = newPieces[index]!
            
            //gets informationat width height and initial block of piece
            let informationTuple = getFromPointers(pointingArr: piece.pointingArr)
            
            //builds piece
            //determines size of piece and saves scale factor
            let blockWidth = piece.startBlockZone.rect.width / CGFloat(informationTuple.1.0) / 1.1
            let blockHeight = piece.startBlockZone.rect.height / 2 / CGFloat(informationTuple.1.1 + 1)
            if(blockWidth < blockHeight) {
                piece.dominantSize = blockWidth
            } else {
                piece.dominantSize = blockHeight
            }
            
            piece.scaleFactor = squareSideLength / 8 / piece.dominantSize
            
            let differenceX = piece.startBlockZone.rect.width - piece.dominantSize * CGFloat(informationTuple.1.0)
            let differenceY = piece.startBlockZone.rect.height - piece.dominantSize * CGFloat(informationTuple.1.1)
            let marginX = piece.startBlockZone.rect.minX + piece.dominantSize * CGFloat(informationTuple.0.0)
            let marginY = piece.startBlockZone.rect.minY + piece.dominantSize  * CGFloat(informationTuple.0.1)
            var startX = marginX + differenceX / 2
            var startY = marginY + differenceY / 2
            
            //initial block
            piece.blocks.append(SKShapeNode(rect: CGRect(x: 0, y: 0, width: piece.dominantSize, height: piece.dominantSize)))
            piece.blocks[0].position.x = startX
            piece.blocks[0].position.y = startY
            piece.blocks[0].zPosition = 3
            piece.blocks[0].fillColor = piece.color
            
            //find border color
            var red = CGFloat(0.0)
            var green = CGFloat(0.0)
            var blue = CGFloat(0.0)
            var alpha = CGFloat(0.0)
            
            piece.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            var colors = [red, green, blue]
            
            for index in 0...2 {
                if(colors[index] > 0.21) {
                    colors[index] -= 0.2
                } else {
                    colors[index] = CGFloat(0)
                }
            }
            
            piece.blocks[0].lineWidth = 4
            piece.blocks[0].strokeColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: CGFloat(1.0))
            
            self.addChild(piece.blocks[0])
            
            //add blocks to initial
            for index in 0...piece.pointingArr.count - 1 {
                
                //Get piece locations in reference to original
                if(piece.pointingArr[index] == 1) {
                    startY += piece.dominantSize
                } else if(piece.pointingArr[index] == 2) {
                    startX += piece.dominantSize
                } else if(piece.pointingArr[index] == 3) {
                    startY -= piece.dominantSize
                } else {
                    startX -= piece.dominantSize
                }
                
                //draw square
                piece.blocks.append(SKShapeNode(rect: CGRect(x: 0, y: 0, width: piece.dominantSize, height: piece.dominantSize)))
                piece.blocks[index+1].position.x = startX
                piece.blocks[index+1].position.y = startY
                piece.blocks[index+1].zPosition = 3
                piece.blocks[index+1].fillColor = piece.color
                
                piece.blocks[index+1].lineWidth = 4
                piece.blocks[index+1].strokeColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: CGFloat(1.0))
                
                self.addChild(piece.blocks[index + 1])
                
            }
        }
    }
    
    func clearCol(col: Int) {
        for index in 0...7 {
            let blockIndex = col + index * 8
            gridInformation.gridArr[blockIndex] = nil
        }
    }
    
    func clearRow(row: Int) {
        for index in 0...7 {
            let blockIndex = row * 8 + index
            gridInformation.gridArr[blockIndex] = nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        //dev playground/Users/jakelonseth/Downloads/blockblastv4-default-rtdb-627720940-export.csv
        //defaults.set(0, forKey: "currentIteration")
        
        let background = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        background.zPosition = 0
        background.fillColor = SKColor(red: 0.11, green: 0.27, blue: 0.59, alpha: 1)
        self.addChild(background)
        
        //High Score Label
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: "
        scoreLabel.fontSize = 62
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: self.size.width / 2 - 100, y: 1850)
        scoreLabel.zPosition = 6
        self.addChild(scoreLabel)
        
        scoreValueLabel.text = String(score)
        scoreValueLabel.fontSize = 62
        scoreValueLabel.fontColor = generateRandomColor()
        scoreValueLabel.position = CGPoint(x: self.size.width / 2 + 200, y: 1850)
        scoreValueLabel.zPosition = 6
        self.addChild(scoreValueLabel)
        
        //Initializes shadow blocks
        for index in 0...8 {
            let tempRect = CGRect(x: 0, y: 0, width: squareSideLength / 8, height: squareSideLength / 8)
            shadowArr.append(SKShapeNode(rect: tempRect))
            shadowArr[index].zPosition = 2
            shadowArr[index].fillColor = UIColor.clear
            shadowArr[index].strokeColor = UIColor.clear
            self.addChild(shadowArr[index])
        }
        
        //Grid setup
        
        let gridLine = SKShapeNode()
        let gridPath = CGMutablePath()
        
        let y1 = gameArea.height / 2
        let y2 = y1 + squareSideLength
        let x1 = squareSideLength / 18 + margin
        let x2 = x1 + squareSideLength
        
        //Create grids line
        for index in 1...7 {
            let increment = squareSideLength / 8
            let xVal = x1 + increment * CGFloat(index)
            let yVal = y1 + increment * CGFloat(index)
            gridPath.move(to: CGPoint(x: xVal, y: y1))
            gridPath.addLine(to: CGPoint(x: xVal, y: y2))
            gridPath.move(to: CGPoint(x: x1, y: yVal))
            gridPath.addLine(to: CGPoint(x: x2, y: yVal))
        }
        
        //Creates seperator between grid and pieces
        gridPath.move(to: CGPoint(x: 0, y: gameArea.height / 12 * 5))
        gridPath.addLine(to: CGPoint(x: 2000, y: gameArea.height / 12 * 5))
        
        //Draws lines
        gridLine.path = gridPath
        gridLine.strokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        gridLine.zPosition = 4
        gridLine.lineWidth = 5
        addChild(gridLine)
        
        //shading
        let gridLightLine = SKShapeNode()
        let gridLightPath = CGMutablePath()
        
        gridLightPath.move(to: CGPoint(x: x1, y: y1))
        gridLightPath.addLine(to: CGPoint(x: x2, y: y1))
        gridLightPath.move(to: CGPoint(x: x2, y: y1))
        gridLightPath.addLine(to: CGPoint(x: x2, y: y2))
        
        gridLightLine.path = gridLightPath
        gridLightLine.strokeColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        gridLightLine.zPosition = 1
        gridLightLine.lineWidth = 10
        addChild(gridLightLine)
        
        let gridDarkLine = SKShapeNode()
        let gridDarkPath = CGMutablePath()
        
        gridDarkPath.move(to: CGPoint(x: x1, y: y2))
        gridDarkPath.addLine(to: CGPoint(x: x2, y: y2))
        gridDarkPath.move(to: CGPoint(x: x1, y: y1))
        gridDarkPath.addLine(to: CGPoint(x: x1, y: y2))
        
        gridDarkLine.path = gridDarkPath
        gridDarkLine.strokeColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1)
        gridDarkLine.zPosition = 1
        gridDarkLine.lineWidth = 10
        addChild(gridDarkLine)

        
        //Fills in grid
        let gridBackground = SKShapeNode(rect: CGRect(x: x1, y: y1, width: x2-x1, height: y2-y1))
        gridBackground.fillColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        gridBackground.zPosition = 0
        self.addChild(gridBackground)
        
        //initializes pieces
        addNewPieces()
        
    }
    
    /*func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
    }
    
    func spawnEnemy(){
        
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        enemy.run(enemySequence)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zPosition = amountToRotate
        
    } */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            activePiece = whichZonePiece(touch: touch.location(in: self))
            
            //saves original points
            if let savedPiece = activePiece.0 {
                savedPoint = savedPiece.blocks[0].position
                                
                //moves block up when clicked
                savedPiece.blocks[0].position.y += 100
                savedPiece.blocks[0].zPosition = 4
                suggestedPosition = savedPiece.blocks[0].position
                shadowArr[0].position.x = savedPiece.blocks[0].position.x + 25
                shadowArr[0].position.y = savedPiece.blocks[0].position.y - 25
                shadowArr[0].fillColor = UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.25)

                
                for index in 0...savedPiece.blocks.count - 1 {
                    savedPiece.blocks[index].zPosition = 4
                    savedPiece.blocks[index].setScale(savedPiece.scaleFactor)
                    
                    //bring blocks together
                    if(index > 0) {
                        if(savedPiece.pointingArr[index-1] == 1) {
                            savedPiece.blocks[index].position.y = savedPiece.blocks[index-1].position.y + savedPiece.dominantSize * savedPiece.scaleFactor
                            savedPiece.blocks[index].position.x = savedPiece.blocks[index-1].position.x
                        } else if(savedPiece.pointingArr[index-1] == 2) {
                            savedPiece.blocks[index].position.x = savedPiece.blocks[index-1].position.x + savedPiece.dominantSize * savedPiece.scaleFactor
                            savedPiece.blocks[index].position.y = savedPiece.blocks[index-1].position.y
                        } else if(savedPiece.pointingArr[index-1] == 3) {
                            savedPiece.blocks[index].position.y = savedPiece.blocks[index-1].position.y - savedPiece.dominantSize * savedPiece.scaleFactor
                            savedPiece.blocks[index].position.x = savedPiece.blocks[index-1].position.x
                        } else {
                            savedPiece.blocks[index].position.x = savedPiece.blocks[index-1].position.x - savedPiece.dominantSize * savedPiece.scaleFactor
                            savedPiece.blocks[index].position.y = savedPiece.blocks[index-1].position.y
                        }
                        
                        shadowArr[index].position.x = savedPiece.blocks[index].position.x + 25
                        shadowArr[index].position.y = savedPiece.blocks[index].position.y - 25
                        shadowArr[index].fillColor = UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.25)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            suggestedPosition.x += pointOfTouch.x - previousPointOfTouch.x
            suggestedPosition.y += pointOfTouch.y - previousPointOfTouch.y
            
            if let movingPiece = activePiece.0 {
                
                if(clearBlockIndicator.count > 0) {
                    for index in 0...clearBlockIndicator.count - 1 {
                        clearBlockIndicator[index].removeFromParent()
                    }
                    clearBlockIndicator = []
                }
                
                let snapData = snapToPosition(inputPoint: suggestedPosition, pointingArr: movingPiece.pointingArr)
                
                //snaps block[0] to grid
                movingPiece.blocks[0].position = snapData.0
                shadowArr[0].position.x = movingPiece.blocks[0].position.x + 25
                shadowArr[0].position.y = movingPiece.blocks[0].position.y - 25
                
                for col in snapData.5 {
                    let startY = gameArea.height / 2
                    let increment = squareSideLength / 8
                    let startX = getPositionOfGridSquare(row: 0, col: col).x
                    
                    for index in 0...7 {
                        let whiteRect = CGRect(x: startX - 2.5, y: startY + increment * CGFloat(index) - 2.5, width: squareSideLength / 8 + 5, height: squareSideLength / 8 + 5)
                        let whiteShape = SKShapeNode(rect: whiteRect)
                        whiteShape.fillColor = UIColor.white
                        whiteShape.zPosition = 10
                        whiteShape.strokeColor = UIColor.clear
                        clearBlockIndicator.append(whiteShape)
                        self.addChild(clearBlockIndicator[clearBlockIndicator.count-1])
                    }
                }
                
                for row in snapData.4 {
                    let startY = getPositionOfGridSquare(row: row, col: 0).y
                    let increment = squareSideLength / 8
                    let startX = squareSideLength / 18 + margin
                    
                    for index in 0...7 {
                        let whiteRect = CGRect(x: startX + increment * CGFloat(index) - 2.5, y: startY - 2.5, width: squareSideLength / 8 + 5, height: squareSideLength / 8 + 5)
                        let whiteShape = SKShapeNode(rect: whiteRect)
                        whiteShape.fillColor = UIColor.white
                        whiteShape.zPosition = 10
                        whiteShape.strokeColor = UIColor.clear
                        clearBlockIndicator.append(whiteShape)
                        self.addChild(clearBlockIndicator[clearBlockIndicator.count-1])
                    }
                }
                
                //sticks other blocks to block 0
                for index in 1...movingPiece.blocks.count - 1 {
                    
                        if(movingPiece.pointingArr[index-1] == 1) {
                            movingPiece.blocks[index].position.y = movingPiece.blocks[index-1].position.y + movingPiece.dominantSize * movingPiece.scaleFactor
                            movingPiece.blocks[index].position.x = movingPiece.blocks[index-1].position.x
                        } else if(movingPiece.pointingArr[index-1] == 2) {
                            movingPiece.blocks[index].position.x = movingPiece.blocks[index-1].position.x + movingPiece.dominantSize * movingPiece.scaleFactor
                            movingPiece.blocks[index].position.y = movingPiece.blocks[index-1].position.y
                        } else if(movingPiece.pointingArr[index-1] == 3) {
                            movingPiece.blocks[index].position.y = movingPiece.blocks[index-1].position.y - movingPiece.dominantSize * movingPiece.scaleFactor
                            movingPiece.blocks[index].position.x = movingPiece.blocks[index-1].position.x
                        } else {
                            movingPiece.blocks[index].position.x = movingPiece.blocks[index-1].position.x - movingPiece.dominantSize * movingPiece.scaleFactor
                            movingPiece.blocks[index].position.y = movingPiece.blocks[index-1].position.y
                        }
                    
                    shadowArr[index].position.x = movingPiece.blocks[index].position.x + 25
                    shadowArr[index].position.y = movingPiece.blocks[index].position.y - 25
                    
                }

            }
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //hides shadow blocks
        for index in 0...8 {
            shadowArr[index].fillColor = UIColor.clear
        }
        
        //hides indicators
        if(clearBlockIndicator.count > 0) {
            for index in 0...clearBlockIndicator.count - 1 {
                clearBlockIndicator[index].removeFromParent()
            }
            clearBlockIndicator = []
        }
        
        if let returningPiece = activePiece.0 {
            
            //determines if block is hovering over empty zone
            let startBlockPoint = returningPiece.blocks[0].position
            let snapTuple = snapToPosition(inputPoint: CGPoint(x: startBlockPoint.x, y: startBlockPoint.y), pointingArr: returningPiece.pointingArr)
            
            if(snapTuple.1) {
                
                let increase = returningPiece.pointingArr.count + 1
                score += increase
                updateScore(changeInScore: increase)
                
                //deletes from newPieces
                newPieces[activePiece.1] = nil
                
                for index in 0...returningPiece.pointingArr.count {
                    returningPiece.blocks[index].removeFromParent()
                    
                    //add blocks to grid
                    var row = snapTuple.2
                    var col = snapTuple.3
                    
                    for blockIndex in -1...returningPiece.pointingArr.count - 1 {
                        
                        if(blockIndex == -1) {
                            gridInformation.gridArr[row * 8 + col] = returningPiece.color
                            
                        } else {
                
                            if(returningPiece.pointingArr[blockIndex] == 0) {
                                col -= 1
                            } else if(returningPiece.pointingArr[blockIndex] == 1) {
                                row += 1
                            } else if(returningPiece.pointingArr[blockIndex] == 2) {
                                col += 1
                            } else {
                                row -= 1
                            }
                            
                            gridInformation.gridArr[row * 8 + col] = returningPiece.color
                            
                        }
                        
                    }
                    
                }
                returningPiece.startBlockZone.piece = nil
                
                //saves grid before blocks are deleted
                let pastGridStatus = gridInformation.gridArr
                
                //if out of blocks
                if(blockZone1.piece == nil && blockZone2.piece == nil && blockZone3.piece == nil) {
                    addNewPieces()
                }
                
                //clears rows and cols
                for row in snapTuple.4 {
                    clearRow(row: row)
                    combo += 1
                }
                
                for col in snapTuple.5 {
                    clearCol(col: col)
                    combo += 1
                }
                
                //Removes old blocks
                self.removeChildren(in: blocksOnGrid)
                blocksOnGrid = []
                blocksOnGridPositions = []
                
                var blockCount = 0
                
                //Draws blocks on grid
                
                
                //DEV
                /*let position = getPositionOfGridSquare(row: 1, col: 1)
                let devRect = CGRect(x: position.x, y: position.y, width: squareSideLength / 8, height: squareSideLength / 8)
                let devSquare = SKShapeNode(rect: devRect)
                devSquare.fillColor = UIColor.white
                devSquare.zPosition = 10
                self.addChild(devSquare) */
                
                for gridIndex in 0...gridInformation.gridArr.count - 1 {
                    if(gridInformation.gridArr[gridIndex] != nil) {
                        
                        let rowCol = gridInformation.getRowCol(index: gridIndex)
                        let position = getPositionOfGridSquare(row: rowCol.0, col: rowCol.1)
                        let color = gridInformation.getColor(row: rowCol.0, col: rowCol.1)
                        
                        //find border color
                        var red = CGFloat(0.0)
                        var green = CGFloat(0.0)
                        var blue = CGFloat(0.0)
                        var alpha = CGFloat(0.0)
                        
                        color!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                        var colors = [red, green, blue]
                        
                        for index in 0...2 {
                            if(colors[index] > 0.21) {
                                colors[index] -= 0.2
                            } else {
                                colors[index] = CGFloat(0)
                            }
                        }
                        
                        //build blokcks
                        blocksOnGridPositions.append((rowCol.0, rowCol.1))
                        blocksOnGrid.append(SKShapeNode(rect: CGRect(x: position.x, y: position.y, width: squareSideLength / 8, height: squareSideLength / 8)))
                        blocksOnGrid[blockCount].fillColor =  color!
                        blocksOnGrid[blockCount].lineWidth = 4
                        blocksOnGrid[blockCount].strokeColor = UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1.0)
                        blocksOnGrid[blockCount].zPosition = 3
                        self.addChild(blocksOnGrid[blockCount])
                        blockCount += 1
                    }
                }
                
                //Checks if any blocks have been deleted
                var deletedBlockIndexes: [Int] = []
                var scoreIncrease = 0.0
                var count = 0
                
                for index in 0...pastGridStatus.count-1 {
                    if(gridInformation.gridArr[index] == nil && pastGridStatus[index] != nil) {
                        
                        count += 1
                        
                        scoreIncrease += 4 / 5 * Double(combo + 1)
                        
                        //makes array of deleted block indexs
                        deletedBlockIndexes.append(index)
                        
                    }
                }
                
                if(scoreIncrease != 0) {
                    let roundedScoreIncrease = Int(scoreIncrease)
                    score += roundedScoreIncrease
                    updateScore(changeInScore: Int(roundedScoreIncrease))
                } else {
                    combo = 0
                }
                
                //adds back deleted blocks
                var ghostBlocks = [SKShapeNode]()
                
                if(deletedBlockIndexes.count > 0) {
                    
                    for index in 0...deletedBlockIndexes.count-1 {
                        let rowCol = gridInformation.getRowCol(index: deletedBlockIndexes[index])
                        let ghostPos = getPositionOfGridSquare(row: rowCol.0, col: rowCol.1)
                        
                        //adds ghost blocks to animate
                        ghostBlocks.append(SKShapeNode(rect: CGRect(x: ghostPos.x, y: ghostPos.y, width: squareSideLength / 8, height: squareSideLength / 8)))
                        ghostBlocks[index].fillColor =  UIColor.white
                        ghostBlocks[index].zPosition = 4
                        self.addChild(ghostBlocks[index])
                        
                        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.5)
                        
                        ghostBlocks[index].run(fadeOut, completion: {
                            ghostBlocks[index].removeFromParent()
                        })
                        
                    }
                }
                
                //checks if any blocks fit
                /*var doesFit = false
                for piece in newPieces {
                    if piece != nil {
                        doesFit = gridInformation.canFit(piece: piece!)
                    }
                    if(doesFit) {
                        break
                    }
                }
                
                if(!doesFit) {
                    
                    sleep(1)
                    
                    //switches scene
                    if let view = self.view {
                        
                        if(score > defaults.integer(forKey: "highscore")) {
                            defaults.set(score, forKey: "highscore")
                        }
                        
                        let scene = GameOverScene(size: CGSize(width: 1536, height: 2048), score: score, highScore: defaults.integer(forKey: "highscore"))
                        
                        scene.scaleMode = .aspectFill
                        view.presentScene(scene)

                    }
                    
                } */
                
            } else {
                
                //if block must return
                returningPiece.blocks[0].position = savedPoint
                returningPiece.blocks[0].setScale(1)
                returningPiece.blocks[0].zPosition = 3
                
                //cycles through blocks
                for index in 1...returningPiece.blocks.count - 1 {
                    returningPiece.blocks[index].zPosition = 3
                    returningPiece.blocks[index].setScale(1)
                    
                    if(index > 0) {
                        if(returningPiece.pointingArr[index-1] == 1) {
                            returningPiece.blocks[index].position.y = returningPiece.blocks[index-1].position.y + returningPiece.dominantSize
                            returningPiece.blocks[index].position.x = returningPiece.blocks[index-1].position.x
                        } else if(returningPiece.pointingArr[index-1] == 2) {
                            returningPiece.blocks[index].position.x = returningPiece.blocks[index-1].position.x + returningPiece.dominantSize
                            returningPiece.blocks[index].position.y = returningPiece.blocks[index-1].position.y
                        } else if(returningPiece.pointingArr[index-1] == 3) {
                            returningPiece.blocks[index].position.y = returningPiece.blocks[index-1].position.y - returningPiece.dominantSize
                            returningPiece.blocks[index].position.x = returningPiece.blocks[index-1].position.x
                        } else {
                            returningPiece.blocks[index].position.x = returningPiece.blocks[index-1].position.x - returningPiece.dominantSize
                            returningPiece.blocks[index].position.y = returningPiece.blocks[index-1].position.y
                        }
                    }
                    
                    //returns to original location and size
                    returningPiece.blocks[index].setScale(1)
                    
                }
            }
        }
        
        //checks if any blocks fit
        var doesFit = false
        for piece in newPieces {
            if piece != nil {
                doesFit = gridInformation.canFit(piece: piece!)
            }
            if(doesFit) {
                break
            }
        }
        
        if(!doesFit) {
            
            sleep(1)
            
            //switches scene
            if let view = self.view {
                
                if(score > defaults.integer(forKey: "highscore")) {
                    defaults.set(score, forKey: "highscore")
                }
                
                let scene = GameOverScene(size: CGSize(width: 1536, height: 2048), score: score, highScore: defaults.integer(forKey: "highscore"), savedData: savedData)
                
                scene.scaleMode = .aspectFill
                view.presentScene(scene)

            }
            
        }
        
    }
}

