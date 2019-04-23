//
//  Review.swift
//  Snacktacular
//
//  Created by Alberto Medina on 4/23/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewerUserId: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["title": title, "text": text, "rating": rating, "reviewerUserId": reviewerUserId, "date": date, "documentID": documentID]
    }
    
    init(title: String,text: String, rating: Int, reviewerUserId: String, date: Date, documentID: String) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewerUserId = reviewerUserId
        self.date = date
        self.documentID = documentID
    }
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["dictionary"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let reviewerUserId = dictionary["reviewerUserId"] as! String
        let date = dictionary["date"] as! Date? ?? Date()
        self.init(title: title, text: text, rating: rating, reviewerUserId: reviewerUserId, date: date, documentID: "")
        
    }
    convenience init() {
        let currentUserID = Auth.auth().currentUser?.email ?? "Unknown User"
        self.init(title: "", text: "", rating: 0, reviewerUserId: currentUserID, date: Date(), documentID: "")
    }
}
func saveData(spot: Spot, completion: @escaping (Bool) -> ()) {
    let db = Firestore.firestore()
    
    let dataToSave = self.dictionary
    
    if self.documentID != "" {
        let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
        ref.setData(dataToSave) { (error) in
            if let error = error {
                print("*** Error updating document \(self.documentID) in spot \(self.documentID) \(error.localizedDescription)")
                completed(false)
            } else {
                print("Document updated with ref ID \(ref.documentID)")
                completed(true)
            }
        }
    } else {
        var ref: DocumentReference? = nil
        ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave) { error in
            if let error = error {
                print("*** Error creating new document in spot \(self.documentID) for new documentID \(error.localizedDescription)")
                completed(false)
            } else {
                print("new Document created with ref ID \(ref.documentID ?? "unknown")")
                completed(true)
            }
        }
    }
    
}
