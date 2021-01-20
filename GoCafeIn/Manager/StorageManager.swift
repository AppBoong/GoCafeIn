//
//  StorageManager.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/11.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import Foundation
import FirebaseStorage

public class StorageManager {
    static let shared = StorageManager()
     
    private let storage = Storage.storage().reference()
    
    public enum GCStorageManagerError : Error {
        case failedToDownload
    }
    public func uploadImage(image : UIImage, completion : @escaping (URL?) -> Void ) {
        guard let imageData = image.jpegData(compressionQuality: 0.1) else {
            return completion(nil)
        }
        let uid = Auth.auth().currentUser?.uid
        let riversRef = storage.child("image\(uid!)").child("\(Int.random(in: 1 ... 1000000000))")
        riversRef.putData(imageData, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
//                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
        riversRef.downloadURL { url,error in
          return completion(url)
        
//            guard let downloadURL = url else {
//                return completion(nil)
//            }

            
                
            }
        }
    }
    public func uploadUserPost(model : UserPost , completion : @escaping (Result<URL, Error>) -> Void) {
       
    }
    public func downloadImage(with reference : String, completion : @escaping (Result<URL, Error>) -> Void) {
        storage.child(reference).downloadURL(completion :{ url, error in
            guard let url = url , error == nil else {
                completion(.failure(GCStorageManagerError.failedToDownload))
                return
            }
            
            completion(.success(url))
        })
    }
    
    
}

public enum UserPostType {
    case photo, video
}

public struct UserPost {
    let postType : UserPostType
    let thumbnailImage : URL
    let postURL : URL
    let caption : String
    let likeCount : Int
    let comments : [PostComment]
    let postDate : Date
}
struct PostLike {
    let username : String
    let PostIdentifier : String
}
struct CommentLike {
    let username : String
    let commentIdentifier : String
}
struct PostComment {
    let identifier : String
    let username : String
    let text : String
    let createdDate : Date
    let likes : [CommentLike]
}
