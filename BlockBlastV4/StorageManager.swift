//
//  StorageManager.swift
//  BlockBlastV4
//
//  Created by Jake Lonseth on 11/17/24.
//

import Foundation

func upload() {
    
    let ref = Database.database().reference()
    let testRef = ref.child("test1")
    testRef.setValue(["num": 1])
    
}
