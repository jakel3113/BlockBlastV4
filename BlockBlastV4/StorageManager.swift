//
//  StorageManager.swift
//  BlockBlastV4
//
//  Created by Jake Lonseth on 11/17/24.
//

import Foundation
import FirebaseDatabase

class StorageManager {
    
    func uploadData(finalScore: Int, currentScore: Int, gridStatus: [Bool], pointingArrIndexes: [Int], blockRotations: [Int], currentIteration: Int, userID: Int) {
        
        let ref = Database.database().reference()
        
        //upload data
        let coreDataRef = ref.child("coreData")
        let coreDataDict: [String: Any] = ["finalScore": finalScore, "currentScore": currentScore, "gridStatus": gridStatus, "pointingArrIndexes": pointingArrIndexes, "blockRotations": blockRotations]
        
        coreDataRef.child(String(userID)).child(String(currentIteration)).setValue(coreDataDict)
    }
    
}
