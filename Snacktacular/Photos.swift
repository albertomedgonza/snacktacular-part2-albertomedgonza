//
//  Photos.swift
//  Snacktacular
//
//  Created by Alberto Medina on 4/23/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Photos {
    var photoArray: [Photo] = []
    var db = Firestore!
    
    init() {
        db = Firestore.firestore()
    }
}
