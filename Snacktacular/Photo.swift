//
//  Photo.swift
//  Snacktacular
//
//  Created by Alberto Medina on 4/23/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Photo {
    var image: UIImage
    var description: String
    var postedBy: String
    var date: Date
    var documentUUID: String
    var dictionary: [String: Any] {
        return ["description": description, "postedBy": postedBy, "date": date]
    }
    init(image: UIImage, description: String, postedBy: String, date: Date, documentUUID: String) {
        self.image = image
        self.description = description
        self.postedBy = postedBy
        self.date = date
        self.documentUUID = documentUUID
    }
    convenience init() {
        let postedBy = Auth.auth().currentUser?.email ?? "unknown user"
        self.init(image: UIImage(), description: "", postedBy: postedBy, date: Date(), documentUUID: "")
    }
    func saveData(spot: Spot, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        //convert photo.image
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("ERROR: could not convert image to data format")
            return completed(false)
        }
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        documentUUID = UUID().uuidString
        // create a red
        let storageRef = storage.reference().child(spot.documentID).child(self.documentUUID)
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) {metadata, error in
            guard error == nil else {
                print("Error during .putadata storage upload for reference \(storageRef). Error \(error!.localizedDescription)")
            }
            print("upload worked! Metadata is: \(metadata)")
        }
        
        uploadTask.observe(.success) { (snapshot) in
            //create dictionary
            let dataToSave = self.dictionary
            // This will either create a new doc at documentUUID or update the existing doc with that name
            let ref = db.collection("spots").document(spot.documentID).collection("photos").document(self.documentUUID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("*** Error updating document \(self.documentUUID) in spot \(self.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("Document updated with ref ID \(ref.documentID)")
                    completed(true)
                }
            }
        }
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("***Error: upload task  for file \(self.documentUUID) failed in spot \(spot.documentID)")
            }
            return completed(false)
        }
        
    }

}
